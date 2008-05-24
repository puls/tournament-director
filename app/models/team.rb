class Team < ActiveRecord::Base
  include Cacheable

  belongs_to :school

  after_destroy :destroy_games

  has_many :team_games
  has_many :games, :through => :team_games
  has_many :players, :dependent => :nullify
  has_many :player_games, :through => :games
  has_many :brackets, :through => :games

  validates_presence_of :school
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :school_id


  def wins(bracket = nil)
	if bracket.nil?
		team_games.clone.select{|g| g.game.play_complete? and g.won?}.length
	else
		team_games.clone.select{|g| g.game.play_complete? and g.game.bracket == bracket and g.won?}.length
	end
  end

  def losses(bracket = nil)
	if bracket.nil?
		team_games.clone.select{|g| g.game.play_complete? and not g.won?}.length
	else
		team_games.clone.select{|g| g.game.play_complete? and g.game.bracket == bracket and not g.won?}.length
	end
  end

  def num_games(bracket = nil)
  	if bracket.nil?
  		games.length
  	else
  		games.select{|g| g.play_complete? and g.bracket == bracket}.length
  	end
  end

  def win_pct(bracket = nil)
  	if num_games(bracket) == 0
  		0.0
	elsif losses(bracket) == 0
		1.0
	else
		wins(bracket).to_f / num_games(bracket).to_f
  	end
  end

  def pf(bracket = nil)
	if bracket.nil?
		team_games.clone.select{|g| g.game.play_complete?}.collect{|g| g.points}.sum || 0
	else
		team_games.clone.select{|g| g.game.play_complete? and g.game.bracket == bracket}.collect{|g| g.points}.sum || 0
	end
  end

  def tuh(bracket = nil)
	if bracket.nil?
		team_games.clone.select{|g| g.game.play_complete?}.collect{|g| g.game.tossups}.sum || 0
	else
		team_games.clone.select{|g| g.game.play_complete? and g.game.bracket == bracket}.collect{|g| g.game.tossups}.sum || 0
	end
  end

  def pf_per(bracket = nil)
  	if num_games(bracket) == 0
  		0.0
  	else
  		pf(bracket).to_f / num_games(bracket).to_f
  	end
  end

  def pa(bracket = nil)
	if bracket.nil?
		team_games.clone.select{|tg| tg.game.play_complete?}.collect{|tg| tg.game.team_games[tg.ordering % 2].points}.sum || 0
	else
		team_games.clone.select{|tg| tg.game.play_complete? and tg.game.bracket == bracket}.collect{|tg| tg.game.team_games[tg.ordering % 2].points}.sum || 0
	end
  end

  def pa_per(bracket = nil)
  	if num_games(bracket) == 0
  		0.0
  	else
  		pa(bracket).to_f / num_games(bracket).to_f
  	end
  end

  def pp20(bracket = nil)
  	if tuh(bracket) == 0
  		0.0
  	else
  		pf(bracket).to_f / (tuh(bracket).to_f / 20.0)
  	end
  end

  def bp(bracket = nil)
	if bracket.nil?
		team_games.select{|tg| tg.game.play_complete? and tg.game.entry_complete?}.collect{|tg| tg.bonus_points}.sum || 0
	else
		team_games.select{|tg| tg.game.play_complete? and tg.game.entry_complete? and tg.game.bracket == bracket}.collect{|tg| tg.bonus_points}.sum || 0
	end
  end

  def tu_correct(bracket = nil)
	if bracket.nil?
		team_games.select{|tg| tg.game.play_complete? and tg.game.entry_complete?}.collect{|tg| tg.tossups_correct}.sum || 0
	else
		team_games.select{|tg| tg.game.play_complete? and tg.game.entry_complete? and tg.game.bracket == bracket}.collect{|tg| tg.tossups_correct}.sum || 0
	end
  end

  def ppbonus(bracket = nil)
  	if tu_correct(bracket) == 0 or tu_correct(bracket).nil?
  		0.0
  	else
  		bp(bracket).to_f / tu_correct(bracket).to_f
  	end
  end

  def destroy_games
  	games.each do |game|
  		game.destroy
  	end
  end

  def reset_all_stats
  	self.stats_cache = {}
  	Bracket.find(:all).push(nil).each do |bracket|
	  	wins(bracket)
  		losses(bracket)
	  	pf(bracket)
  		pa(bracket)
	  	bp(bracket)
  		tu_correct(bracket)
  	end
  end

  def reset_game_stats
  	Bracket.find(:all).push(nil).each do |bracket|
  		wins(bracket, true)
  		losses(bracket, true)
  		pf(bracket, true)
  		pa(bracket, true)
  	end
  end

  def reset_indiv_stats
  	Bracket.find(:all).push(nil).each do |bracket|
  		bp(bracket, true)
  		tu_correct(bracket, true)
  	end
  end

  def start_bracket(bracket)
  	if not (stats_cache.is_a? Hash)
  		self.stats_cache = {}
  		save
  	end

  	if stats_cache[bracket.nil? ? :all : bracket.id].nil?
  		stats_cache[bracket.nil? ? :all : bracket.id] = {}
  		save
  	end
  end

  serializes_results_in :stats_cache
  serializes_result_of :wins, :losses, :pf, :pa, :bp, :tu_correct
  caches_result_of :num_games, :win_pct, :pf_per, :pa_per, :pp20, :ppbonus

end
