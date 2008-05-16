class School < ActiveRecord::Base
  has_many :teams, :order => 'teams.name', :include => :players
  has_and_belongs_to_many :tournaments
end
