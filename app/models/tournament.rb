class Tournament < ActiveRecord::Base
  #attr_accessor :power
  has_many :brackets
  has_many :cards
  has_many :rounds
  has_many :games, :through => :rounds
  has_many :question_types
  has_many :rooms
  has_many :teams
  #has_and_belongs_to_many :schools, :through => :teams
end
