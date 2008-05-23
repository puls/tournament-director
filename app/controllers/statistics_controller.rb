class StatisticsController < ApplicationController

  caches_page :standings,:personal,:team,:ppb,:scoreboard,:aggregate
  before_filter :load_configuration

  def index
    redirect_to :action => "standings"
  end
  
  def standings
  	@brackets = Bracket.find(:all, :include => {:games => {:teams => :team_games}}).push nil
  	@allteams = Team.find(:all, :include => {:team_games => {:game => [:teams, :team_games]}})
	@allteams.sort!{|a,b| sort_teams(a,b,nil)}
    	@max_round = Round.maximum('number')
    	
    	@teams = {}
    	@brackets.each do |bracket|
	    	@teams[bracket] = bracket.teams.sort{|a,b| sort_teams(a,b,bracket)} unless bracket.nil?
	end
  end
  
  def scoreboard
  	@rounds = Round.find(:all, :order => 'number, team_games.points desc', :include => {:games => [{:team_games => :team}, :room]})
  	teams = Team.find(:all, :order => 'name', :include => {:games => :round})
  	@byes = Hash.new
  	
  	@rounds.each do |round|
  	  @byes[round.id] = Array.new
	  end
	  
	  teams.each do |team|
	    round_ids = team.games.collect{|g| g.round.id}
	    @rounds.each do |round|
	      @byes[round.id] << team.name unless round_ids.include?(round.id)
      end
    end
  end
  
  def team
  	begin
  		@team = Team.find(params[:id], :include => [:games, {:players => :player_games}])
  	rescue ActiveRecord::RecordNotFound
  		
  	end
  end
  
  def personal
  
  end
  
  def sort_teams(a,b,bracket)
  	if a.wins(bracket) == b.wins(bracket)
  		b.pp20(bracket) <=> a.pp20(bracket)
  	else
  		b.wins(bracket) <=> a.wins(bracket)
  	end
  end

end
