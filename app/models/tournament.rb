class Tournament < ActiveRecord::Base
  #attr_accessor :power
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :database
  validates_uniqueness_of :database
  validates_numericality_of :tuh_cutoff, :integer_only => true, :allow_nil => true
  
end
