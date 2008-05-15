class TeamGame < ActiveRecord::Base
  belongs_to :team
  belongs_to :game
  has_many :player_games
end
