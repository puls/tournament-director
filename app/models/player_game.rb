class PlayerGame < ActiveRecord::Base
  belongs_to :player
  belongs_to :team_game
  has_many :stat_lines
  
end
