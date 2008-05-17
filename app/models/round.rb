class Round < ActiveRecord::Base
  has_many :games
  
  validates_numericality_of :number, :only_integer => true
end
