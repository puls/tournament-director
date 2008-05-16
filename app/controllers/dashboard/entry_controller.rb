class Dashboard::EntryController < DashboardController
  
  before_filter :check_configuration
  
  def index
    
  end

  def teams_for_round
  	@teams = Team.find(:all, :order => 'name').select{|t| t.games.select{|g| g.round.number == params[:id].to_i }.empty? }
	render :partial => 'teams_for_round', :collection => @teams  
  end  
  
  def bracket_for_team
  
  end
  
  def save_game
  	if params[:round_number].empty?
  		flash[:error] = "Round number cannot be empty."
  		redirect_to :action => 'index'
  	end
  	
  	begin
  		round = Round.find_by_number(params[:round_number])
  	rescue ActiveRecord::RecordNotFound
  		last = Round.find(:first, :order => 'number desc')
  		if last.nil?
  			last = 1
  		else
  			last = last.number
  		end
  		round = Round.new(:number => last)
  		round.save
  	end
  	
  	if round.nil?
  		last = Round.find(:first, :order => 'number desc')
  		if last.nil?
  			last = 1
  		else
  			last = last.number
  		end
  		round = Round.new(:number => last)
  		round.save
  	end
  	  	
  	game = round.games.build(:round => round, :tossups => params[:tossups], :extragame => params[:extragame], :overtime => params[:overtime], :playoffs => params[:playoffs], :forfeit => params[:forfeit])
  	game.room = Room.find(params[:room]) if @tournament.tracks_rooms
  	game.bracket = Bracket.find(params[:bracket]) if @tournament.bracketed
    	
    	tg1 = game.team_games.build(:team => Team.find(params[:team1]), :points => params[:score1])
    	tg1.card = Card.find(params[:card1]) if @tournament.swiss
    	
    	tg2 = game.team_games.build(:team => Team.find(params[:team2]), :points => params[:score2])
    	tg2.card = Card.find(params[:card2]) if @tournament.swiss
    	
    	game.save
    	tg1.save
    	tg2.save
    	
    	flash[:notice] = "Game saved."
    	redirect_to :action => 'index'
  end
  
end
