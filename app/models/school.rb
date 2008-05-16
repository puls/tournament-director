class School < ActiveRecord::Base
  has_many :teams, :order => 'teams.name', :include => :players
end
