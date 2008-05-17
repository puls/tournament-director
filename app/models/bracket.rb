class Bracket < ActiveRecord::Base
  has_many :games
  has_many :teams, :through => :games

  validates_uniqueness_of :name, :case_sensitive => false
  validates_numericality_of :ordering, :allow_nil => true
  
end
