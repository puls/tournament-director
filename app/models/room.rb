class Room < ActiveRecord::Base
  has_many :games
  has_many :rounds, :through => :games

  validates_uniqueness_of :name, :case_sensitive => false
end
