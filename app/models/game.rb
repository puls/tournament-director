class Game < ActiveRecord::Base
  belongs_to :round
  belongs_to :bracket
  belongs_to :room
  has_many :team_games, :dependent => :destroy, :order => 'ordering', :include => [:card, :team]
  has_many :teams, :through => :team_games
  has_many :player_games, :through => :team_games
  
  validates_presence_of :round
  validates_presence_of :tossups
  validates_numericality_of :tossups, :only_integer => true

#  def team_game_for(team)
#  	self.team_games.find(:first, :conditions => {:team_id => team.id})
#  end
  
#  def team_game_for_other(team)
#  	otherteam = self.teams.reject{|b| b == team}.first
#  	if otherteam.nil? 
#  		otherteam = team
#  	end
#  	self.team_games.find(:first, :conditions => {:team_id => otherteam.id})
#  end

end
