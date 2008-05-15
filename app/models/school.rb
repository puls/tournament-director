class School < ActiveRecord::Base
  has_many :teams
  has_many :tournaments, :through => :teams
end
