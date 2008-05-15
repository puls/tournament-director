class Team < ActiveRecord::Base
  belongs_to :school
  belongs_to :tournament

  has_many :team_games
  has_many :games, :through => :team_games, :include => :round, :order => "round_num"

  has_many :players
  has_many :player_games, :through => :games

  has_and_belongs_to_many :brackets, :through => :games

end
