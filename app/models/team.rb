class Team < ActiveRecord::Base
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
  
  serialize :stats_cache
  
  def after_initialize
	  @stats = {}
  end
  
  def wins(bracket = nil, reload = false)
	start_bracket(bracket)
	if reload or @stats[bracket.nil? ? :all : bracket.id][:wins].nil?
		if bracket.nil?
			@stats[:all][:wins] = team_games.clone.select{|g| g.won?}.length
		else
			@stats[bracket.id][:wins] = team_games.clone.select{|g| g.game.bracket == bracket and g.won?}.length
		end
	end
	
	@stats[bracket.nil? ? :all : bracket.id][:wins]
  end
  
  def losses(bracket = nil, reload = false)
	start_bracket(bracket)
	if reload or @stats[bracket.nil? ? :all : bracket.id][:losses].nil?		
		if bracket.nil?
			@stats[:all][:losses] = team_games.clone.select{|g| not g.won?}.length
		else
			@stats[bracket.id][:losses] = team_games.clone.select{|g| g.game.bracket == bracket and not g.won?}.length
		end
	end
	
	@stats[bracket.nil? ? :all : bracket.id][:losses]
  end
  
  def num_games(bracket = nil)
  	if bracket.nil?
  		games.length
  	else
  		games.select{|g| g.bracket == bracket}.length
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
  
  def pf(bracket = nil, reload = false)
	start_bracket(bracket)
  	if reload or @stats[bracket.nil? ? :all : bracket.id][:pf].nil?
  		if bracket.nil?
  			@stats[:all][:pf] = team_games.clone.collect{|g| g.points}.sum
  		else
  			@stats[bracket.id][:pf] = team_games.clone.select{|g| g.game.bracket == bracket}.collect{|g| g.points}.sum
  		end
  	end
  	
  	@stats[bracket.nil? ? :all : bracket.id][:pf]
  end
  
  def tuh(bracket = nil, reload = false)
	start_bracket(bracket)
  	if reload or @stats[bracket.nil? ? :all : bracket.id][:tuh].nil?
  		if bracket.nil?
  			@stats[:all][:tuh] = team_games.clone.collect{|g| g.game.tossups}.sum
  		else
  			@stats[bracket.id][:tuh] = team_games.clone.select{|g| g.game.bracket == bracket}.collect{|g| g.game.tossups}.sum
  		end
  	end
  	
  	@stats[bracket.nil? ? :all : bracket.id][:tuh]
  end
  
  def pf_per(bracket = nil)
  	if num_games(bracket) == 0
  		0.0
  	else
  		pf(bracket).to_f / num_games(bracket).to_f
  	end
  end
  
  def pa(bracket = nil, reload = false)
	start_bracket(bracket)
  	if reload or @stats[bracket.nil? ? :all : bracket.id][:pa].nil?
  		if bracket.nil?
  			@stats[:all][:pa] = team_games.clone.collect{|tg| tg.game.team_games[tg.ordering % 2].points}.sum
  		else
  			@stats[bracket.id][:pa] = team_games.clone.select{|tg| tg.game.bracket == bracket}.collect{|tg| tg.game.team_games[tg.ordering % 2].points}.sum
  		end
  	end
  	
  	@stats[bracket.nil? ? :all : bracket.id][:pa]
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
  
  def bp(bracket = nil, reload = false)
	start_bracket(bracket)
	if reload or @stats[bracket.nil? ? :all : bracket.id][:bp].nil?
		if bracket.nil?
			@stats[:all][:bp] = team_games.select{|tg| tg.game.entry_complete?}.collect{|tg| tg.bonus_points}.sum
		else
			@stats[bracket.id][:bp] = team_games.select{|tg| tg.game.entry_complete? and tg.game.bracket == bracket}.collect{|tg| tg.bonus_points}.sum
		end
	end  	
	
	@stats[bracket.nil? ? :all : bracket.id][:bp]
  end
  
  def tu_correct(bracket = nil, reload = false)
	start_bracket(bracket)
  	if reload or @stats[bracket.nil? ? :all : bracket.id][:tu_correct].nil?
  		if bracket.nil?
  			@stats[:all][:tu_correct] = team_games.select{|tg| tg.game.entry_complete?}.collect{|tg| tg.tossups_correct}.sum
  		else
  			@stats[bracket.id][:tu_correct] = team_games.select{|tg| tg.game.entry_complete? and tg.game.bracket == bracket}.collect{|tg| tg.tossups_correct}.sum
  		end
  	end
  	
  	@stats[bracket.nil? ? :all : bracket.id][:tu_correct]
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
  
  protected
  def start_bracket(bracket)
  	if @stats[bracket.nil? ? :all : bracket.id].nil?
  		@stats[bracket.nil? ? :all : bracket.id] = {}
  	end
  end

end
