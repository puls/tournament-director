class Player < ActiveRecord::Base
  include Cacheable

  belongs_to :team, :include => :school
  has_many :player_games, :dependent => :nullify, :include => :stat_lines
  has_many :stat_lines, :through => :player_games
  has_many :team_games, :through => :player_games

  validates_presence_of :team
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :team_id
  validates_numericality_of :year, :only_integer => true, :allow_nil => true
  validates_numericality_of :qpin, :only_integer => true, :allow_nil => true

  def non_extra_player_games
    player_games.select{|pg| not pg.team_game.game.extragame?}
  end

  def after_find
    if not stats_cache.is_a? Hash
      self.stats_cache = {}
    end
  end

  def gp(arg = nil)
    pgs = $tournament.count_playoffs_for_personal? ? non_extra_player_games : non_extra_player_games.select{|pg| not pg.team_game.game.playoffs?}
    pgs.inject(0) do |sum, pg|
      sum + (pg.tossups_heard.to_f / pg.team_game.game.tossups.to_f)
    end
  end

  def answered(type)
    if $tournament.count_playoffs_for_personal? then
      stat_lines.find(:all, :conditions => ['question_type_id = ?', type.id]).select{|sl| not sl.player_game.team_game.game.extragame?}.collect{|sl| sl.number}.sum || 0
    else
      stat_lines.find(:all, :conditions => ['question_type_id = ?', type.id]).select{|sl| not sl.player_game.team_game.game.extragame? and not sl.player_game.team_game.game.playoffs?}.collect{|sl| sl.number}.sum || 0
    end
  end

  def tuh(arg = nil)
    if $tournament.count_playoffs_for_personal? then
      non_extra_player_games.collect{|pg| pg.tossups_heard}.sum || 0    
    else
      non_extra_player_games.select{|pg| not pg.team_game.game.playoffs?}.collect{|pg| pg.tossups_heard}.sum || 0
    end
  end

  def points(arg = nil)
    QuestionType.find(:all).collect{|qt| answered(qt) * qt.value}.sum || 0
  end

  def ppg(arg = nil)
    if gp == 0.0
      0.0
    else
      points.to_f / gp
    end
  end

  def pp20(arg = nil)
    if tuh == 0
      0.0
    else
      points.to_f / (tuh.to_f / 20.0)
    end
  end

  def tossups(arg = nil)
    QuestionType.find(:all, :conditions => 'value >= 0').collect{|qt| answered(qt)}.sum || 0
  end

  def negs(arg = nil)
    QuestionType.find(:all, :conditions => 'value < 0').collect{|qt| answered(qt)}.sum || 0
  end

  def tu_neg(arg = nil)
    if negs == 0
      "--"
    else
      tossups.to_f / negs.to_f
    end
  end

  def npg(arg = nil)
    if gp == 0.0
      0.0
    else
      negs.to_f / gp
    end
  end

  def neg20(arg = nil)
    if tuh == 0
      0.0
    else
      negs.to_f / (tuh.to_f / 20.0)
    end
  end

  serializes_results_in :stats_cache
  serializes_result_of :gp, :answered, :tuh
  caches_result_of :points, :ppg, :pp20, :tu_neg, :tossups, :negs, :neg20, :npg
end
