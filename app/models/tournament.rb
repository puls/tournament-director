class Tournament < ActiveRecord::Base
  #attr_accessor :power
  
  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :database
  
end
