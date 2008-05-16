class Player < ActiveRecord::Base
  belongs_to :team, :include => :school
  has_many :player_games
  has_many :stat_lines, :through => :player_games
  has_many :team_games, :through => :player_games
end
