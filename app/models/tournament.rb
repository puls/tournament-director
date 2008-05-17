class Tournament < ActiveRecord::Base
  #attr_accessor :power
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :database
  validates_uniqueness_of :database
  
end
