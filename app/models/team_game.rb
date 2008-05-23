class TeamGame < ActiveRecord::Base
  belongs_to :team
  belongs_to :game
  has_many :player_games, :dependent => :destroy
  
  validates_presence_of :game
  validates_numericality_of :points, :only_integer => true, :allow_nil => true
  validates_numericality_of :tossups_correct, :only_integer => true, :allow_nil => true
  validates_numericality_of :tossup_points, :only_integer => true, :allow_nil => true
  validates_numericality_of :bonus_points, :only_integer => true, :allow_nil => true
  validate :pts_mod_5
  
  def pts_mod_5
  	errors.add_to_base("Points must be 0 mod 5") unless (points.nil? || points % 5 == 0)
  end
  
end
