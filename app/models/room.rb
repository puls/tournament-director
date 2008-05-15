class Room < ActiveRecord::Base
  belongs_to :tournament
  has_many :games
  has_many :rounds, :through => :games

end
