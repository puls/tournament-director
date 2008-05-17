class PlayerGame < ActiveRecord::Base
  belongs_to :player
  belongs_to :team_game
  has_many :stat_lines, :dependent => :destroy
  
  validates_presence_of :player
  validates_presence_of :team_game
  validates_presence_of :tossups_heard
  validates_numericality_of :tossups_heard, :only_integer => true
end
