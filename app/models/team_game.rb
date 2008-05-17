class TeamGame < ActiveRecord::Base
  belongs_to :team
  belongs_to :game
  belongs_to :card
  has_many :player_games
  
  validates_presence_of :team
  validates_presence_of :game
  validates_numericality_of :points, :only_integer => true
  validate :pts_mod_5
  
  def pts_mod_5
  	errors.add_to_base("Points must be 0 mod 5") unless (points % 5 == 0)
  end
  
end
