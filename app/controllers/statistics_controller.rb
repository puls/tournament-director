class StatisticsController < ApplicationController

  caches_page :standings,:personal,:team,:ppb,:scoreboard,:aggregate
  before_filter :load_configuration

  def index
    redirect_to :action => "standings"
  end
  
  def standings
  	@allteams = Team.find(:all)
    	@allteams.sort!{|a,b| (b.win_pct <=> a.win_pct) == 0 ? b.wins <=> a.wins : b.win_pct <=> a.win_pct}
    	@max_round = Round.maximum('number')
    	@brackets = Bracket.find(:all).push nil
    	
    	@teams = {}
    	@brackets.each do |bracket|
	    	@teams[bracket] = bracket.nil? ? Team.find(:all) : bracket.teams
	    	@teams[bracket].sort!{|a,b| sort_teams(a,b,bracket)}
	end
  end
  
  def scoreboard
  	@rounds = Round.find(:all, :order => 'number', :include => {:games => [{:team_games => :team}, :room]})
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
  
  def sort_teams(a,b,bracket)
  	if a.wins(bracket) == b.wins(bracket)
  		b.pp20(bracket) <=> a.pp20(bracket)
  	else
  		b.wins(bracket) <=> a.wins(bracket)
  	end
  end

end
