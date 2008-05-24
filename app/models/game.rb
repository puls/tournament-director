class Game < ActiveRecord::Base
  belongs_to :round
  belongs_to :bracket
  belongs_to :room
  has_many :team_games, :dependent => :destroy, :include => [:team], :order => "ordering"
  has_many :teams, :through => :team_games
  has_many :player_games, :through => :team_games
  
  validates_presence_of :round
  validates_numericality_of :tossups, :only_integer => true, :allow_nil => true

  def sorted_team_games
    team_games.sort_by {|tg|tg.ordering}
  end

  def description
    (tg0, tg1) = sorted_team_games
    result = "Round #{round.number}: "
    result << tg0.team.name
    result << " (card #{tg0.card})" if $tournament.swiss?
    result << " <b>#{tg0.points}</b>"

    result << " &ndash; "

    result << tg1.team.name
    result << " (card #{tg1.card})" if $tournament.swiss?
    result << " <b>#{tg1.points}</b>"
    
    result
  end
  

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
