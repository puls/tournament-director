class Team < ActiveRecord::Base
  belongs_to :school
  
  after_destroy :destroy_games

  has_many :team_games
  has_many :games, :through => :team_games
  has_many :players, :dependent => :nullify
  has_many :player_games, :through => :games
  has_many :brackets, :through => :games
  
  validates_presence_of :school
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :school_id
  
  def after_initialize
	  @stats = {:wins => -1, :losses => -1, :pct => -1}
  end
  
  def wins(reload = false)
  	if reload or @stats[:wins] == -1
	  	@stats[:wins] = team_games.clone.select{|g| g.won?}.length
	end
	@stats[:wins]
  end
  
  def losses(reload = false)
  	if reload or @stats[:losses] == -1
	  	@stats[:losses] = team_games.clone.select{|g| not g.won?}.length
	end
	@stats[:losses]
  end
  
  def num_games
  	games.count
  end
  
  def win_pct
  	if num_games == 0
  		0.0
	elsif losses == 0
		1.0
	else
		wins.to_f / num_games.to_f
  	end
  end
  
  def destroy_games
  	games.each do |game|
  		game.destroy
  	end  	
  end

end
