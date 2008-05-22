class Room < ActiveRecord::Base
  has_many :games, :dependent => :nullify, :include => :round, :order => "rounds.number"
  has_many :rounds, :through => :games

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
end
