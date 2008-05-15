class Player < ActiveRecord::Base
  belongs_to :team
  belongs_to :school, :through => :team
  has_many :player_games
  has_many :stat_lines, :through => :player_games
  has_many :team_games, :through => :player_games
end
