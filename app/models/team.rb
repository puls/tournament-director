class Team < ActiveRecord::Base
  belongs_to :school

  has_many :team_games
  has_many :games, :through => :team_games #, :include => :round, :order => "number"

  has_many :players
  has_many :player_games, :through => :games

  has_many :brackets, :through => :games

end
