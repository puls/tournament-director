class Card < ActiveRecord::Base
	has_many :team_games
	validates_numericality_of :number, :only_integer => true
  
end
