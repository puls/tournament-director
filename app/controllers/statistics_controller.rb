class StatisticsController < ApplicationController

  caches_page :standings,:personal,:team,:ppb,:scoreboard,:aggregate
  before_filter :load_configuration

  def index
    redirect_to :action => "standings"
  end

  def standings
    @brackets = Bracket.find(:all).push nil
    @allteams = Team.find(:all, :include => [{:team_games => {:game => :bracket}}, :games, :school])
    @allteams.sort!{|a,b| sort_teams(a,b,nil)}
    round = Round.find(:first, :order => 'number', :conditions => ["play_complete is null or play_complete != ?", true])
    if (round.nil?)
      round = Round.find(:first, :order => 'number desc')
    end

    @max_round = round.number
    @teams = Hash.new
    @brackets.each do |bracket|
      @teams[bracket] = @allteams.select{|t| not t.games.select{|g| g.bracket == bracket}.empty? }.sort{|a,b| sort_teams(a,b,bracket)} unless bracket.nil?
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
	      @byes[round.id] << team.name unless (round_ids.include?(round.id) || round.number > 14)
      end
    end
  end

  def playoffs
  	@rounds = Round.find(:all, :order => 'number', :include => {:games => [{:team_games => :team}, :room]}, :conditions => "round_id > 14")
  	@rounds.each do |round|
  	  @winner_games[round.id] = round.games
	  end
  end

  def team
  	begin
  		@team = Team.find(params[:id], :include => [{:games => [:room, {:team_games => :team}]}, {:players => :player_games}], :conditions => ['games.play_complete = ?', true])
  	rescue ActiveRecord::RecordNotFound
  		flash[:error] = "Team was not found."
                redirect_to :action => 'standings'
  	end

  	@types = QuestionType.find(:all, :order => 'value desc')
  end

  def personal
    @players_all = Player.find(:all, :include => [:team, {:player_games => :team_game}]).select{|p| not p.team.nil?}.sort{|a,b| sort_players(a,b)}
    @players_tuh_cut = @players_all.select{|p| $tournament.tuh_cutoff.nil? or p.tuh >= $tournament.tuh_cutoff}
    @players_neg = @players_all.sort{|a,b| sort_negs(a,b)}[0,30]

  	round = Round.find(:first, :order => 'number', :conditions => ["play_complete is null or play_complete != ?", true])
  	if (round.nil?)
  	  round = Round.find(:first, :order => 'number desc')
	  end

    @max_round = round.number
    @types = QuestionType.find(:all, :order => 'value desc')
    @negtypes = QuestionType.find(:all, :conditions => ['value < 0'], :order => 'value')
  end

  def sort_teams(a,b,bracket)
  	if a.wins(bracket) == b.wins(bracket)
  		b.pp20(bracket) <=> a.pp20(bracket)
  	else
  		b.wins(bracket) <=> a.wins(bracket)
  	end
  end

  def sort_players(a,b)
    if a.pp20 == b.pp20
      b.points <=> a.points
    else
      b.pp20 <=> a.pp20
    end
  end

  def sort_negs(a,b)
    if a.tu_neg.to_f == b.tu_neg.to_f
      b.neg20 <=> a.neg20
    else
      b.tu_neg.to_f <=> a.tu_neg.to_f
    end
  end

end
