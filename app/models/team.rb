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
  
  def wins
  	team_games.clone.select{|g| g.won?}.length
  end
  
  def losses
  	team_games.clone.select{|g| not g.won?}.length
  end
  
  def win_pct
  	if losses == 0 and wins == 0
  		0.0
  	elsif losses == 0
  		1.0
  	else
  		wins / (team_games.length)
  	end
  end

end
