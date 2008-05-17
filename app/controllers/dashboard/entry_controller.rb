class Dashboard::EntryController < DashboardController
  
  before_filter :check_configuration
  
  def index
  	@last_round = Round.find(:first, :order => 'number desc')
  	if @last_round.nil?
  		@last_round = 1
  	else
  		@last_round = @last_round.number
  	end
  	
  	@games_to_enter = Game.find(:all, :conditions => ['entry_complete IS NULL OR entry_complete = ?', 'f'], :include => :team_games)
  	@teams_to_enter = @games_to_enter.collect{|g| g.teams}.flatten.uniq.sort{|a,b| a.name <=> b.name}
  	
  end

  def teams_for_round
  	@teams = get_teams_for_round params[:id].to_i
	render :partial => 'options_for_round', :collection => @teams  
  end
  
  def get_teams_for_round(round)
    	Team.find(:all, :order => 'name').select{|t| t.games.select{|g| g.round.number == round }.empty? }
  end
  
  def rooms_for_round
  	@rooms = get_rooms_for_round params[:id].to_i
  	render :partial => 'options_for_round', :collection => @rooms
  end
  
  def get_rooms_for_round(round)
    	Room.find(:all, :order => 'name').select{|r| r.games.select{|g| g.round.number == round }.empty? }
  end
  
  def get_cards_for_round(round)
  	Card.find(:all, :order => 'number').select{|c| c.team_games.select{|tg| tg.game.round.number == round }.empty? }
  end
  
  def bracket_for_team
  
  end
  
  def save_game
  	if params[:round_number].empty?
  		flash[:error] = "Round number cannot be empty."
  		redirect_to :action => 'index'
  		return false
  	end
  	
 	round = Round.find_or_create_by_number(params[:round_number])
  	
  	if round.nil?
  		last = Round.find(:first, :order => 'number desc')
  		if last.nil?
  			last = 0
  		else
  			last = last.number
  		end
  		round = Round.new(:number => last+1)
  		round.save
  	end

	if params[:team1] == params[:team2]
		flash[:error] = "You cannot select the same team for both slots."
		redirect_to :action => 'index'
		return false
	end	
  	
  	if params[:score1].to_i == params[:score2].to_i and not params[:forfeit]
  		flash[:error] = "Scores cannot be equal in a non-forfeit."
  		redirect_to :action => 'index'
  		return false
  	end

	teams = get_teams_for_round(round.number)
	rooms = get_rooms_for_round(round.number)
	cards = get_cards_for_round(round.number)
	
	if not params[:extragame] and not (teams.include? Team.find(params[:team1]) and teams.include? Team.find(params[:team2]))
		flash[:error] = "One or both teams has already played a game this round."
		redirect_to :action => 'index'
		return false
	end
	
	if @tournament.tracks_rooms  and not params[:extragame] and not rooms.include? Room.find(params[:room])
		flash[:error] = "That room has already been used during this round."
		redirect_to :action => 'index'
		return false
	end
	
	if @tournament.swiss and not params[:extragame] and not (cards.include? Card.find(params[:card1]) and cards.include? Card.find(params[:card2]) )
		flash[:error] = "One or both cards has already been used during this round."
		redirect_to :action => 'index'
		return false
	end
	
  	game = round.games.build(:round => round, :tossups => params[:tossups], :extragame => params[:extragame], :overtime => params[:overtime], :playoffs => params[:playoffs], :forfeit => params[:forfeit])
  	game.room = Room.find(params[:room]) if @tournament.tracks_rooms
  	game.bracket = Bracket.find(params[:bracket]) if @tournament.bracketed
    	
    	if not game.save
    		game.errors.each_full {|msg| flash[:error] = msg }
    		redirect_to :action => "index"
    		return false
    	end
    	
	tg1 = game.team_games.build(:team => Team.find(params[:team1]), :points => params[:score1])
    	tg1.card = Card.find(params[:card1]) if @tournament.swiss
    	
    	tg2 = game.team_games.build(:team => Team.find(params[:team2]), :points => params[:score2])
    	tg2.card = Card.find(params[:card2]) if @tournament.swiss
    		
    	if not tg1.save
    		tg1.errors.each_full {|msg| flash[:error] = msg }
    		game.destroy
    		redirect_to :action => "index"
    		return false
    	end
    		
    	if not tg2.save
    		tg1.errors.each_full {|msg| flash[:error] = msg }
    		game.destroy
    		redirect_to :action => "index"
    		return false
    	end
    		
    	flash[:notice] = "Game saved."
    	redirect_to :action => 'index'
  end
  
end
