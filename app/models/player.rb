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
  
  serialize :stats_cache
end
