class School < ActiveRecord::Base
  has_many :teams, :order => 'teams.name', :include => :players
  
  validates_uniqueness_of :name, :scope => :city
end
