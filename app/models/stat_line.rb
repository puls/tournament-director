class StatLine < ActiveRecord::Base
  belongs_to :player_game
  belongs_to :question_type
  
end
