class Game < ActiveRecord::Base
  belongs_to :round
  belongs_to :bracket
  belongs_to :room
  belongs_to :tournament, :through => :round
  has_many :team_games
  has_many :teams, :through => :team_games
  has_many :player_games, :through => :team_games

end
