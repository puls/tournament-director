class Bracket < ActiveRecord::Base
  has_many :games, :dependent => :nullify

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_numericality_of :ordering, :allow_nil => true, :only_integer => true

  def teams
  	games.collect{|g| g.teams}.flatten.uniq
  end
  
end
