class Room < ActiveRecord::Base
  has_many :games
  has_many :rounds, :through => :games

end
