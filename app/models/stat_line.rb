class StatLine < ActiveRecord::Base
  belongs_to :player_game
  belongs_to :question_type

  validates_presence_of :question_type
  validates_presence_of :player_game
  validates_presence_of :number
  validates_numericality_of :number, :only_integer => true  
end
