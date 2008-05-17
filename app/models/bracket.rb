class Bracket < ActiveRecord::Base
  has_many :games, :dependent => :nullify
  has_many :teams, :through => :games, :dependent => :nullify

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_numericality_of :ordering, :allow_nil => true
  
end
