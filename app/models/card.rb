class Card < ActiveRecord::Base
	has_many :team_games, :dependent => :nullify
	
	validates_presence_of :number
	validates_numericality_of :number, :only_integer => true
end
