class Team < ActiveRecord::Base
  belongs_to :school

  has_many :team_games, :dependent => :destroy
  has_many :games, :through => :team_games #, :include => :round, :order => "number"
  has_many :players, :dependent => :nullify
  has_many :player_games, :through => :games
  has_many :brackets, :through => :games
  
  validates_presence_of :school
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :school_id

end
