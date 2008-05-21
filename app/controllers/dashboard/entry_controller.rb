class Dashboard::EntryController < DashboardController
  
  before_filter :check_configuration
  
  def index
  	@last_round = Round.find(:first, :order => 'number desc')
  	if @last_round.nil?
  		@last_round = 1
  	else
  		@last_round = @last_round.number
  	end
  	
  	@rounds_to_enter = Round.find(:all, :conditions => ['rounds.entry_complete IS NULL OR rounds.entry_complete != ?', 't'], :include => :games)
  	
  end

  def teams_for_round
  	allt = params[:editing] ? true : false
  	@teams = get_teams_for_round params[:id].to_i, allt
	render :partial => 'options_for_round', :collection => @teams, :locals => {:eltsel => nil}
  end
  
  def get_teams_for_round(round, allt = false)
  	if allt
  		Team.find(:all, :order => 'name')
  	else
	    	Team.find(:all, :order => 'name').select{|t| t.games.select{|g| g.round.number == round }.empty? }
	end
  end
  
  def rooms_for_round
  	allr = params[:editing] ? true : false
  	@rooms = get_rooms_for_round params[:id].to_i, allr
	render :partial => 'options_for_round', :collection => @rooms, :locals => {:eltsel => params[:selected].nil? ? false : params[:selected]}
  end
  
  def get_rooms_for_round(round, allr = false)
  	if allr
  		Room.find(:all, :order => 'name')
  	else
    		Room.find(:all, :order => 'name').select{|r| r.games.select{|g| g.round.number == round }.empty? }
    	end
  end
  
  def get_cards_for_round(round, allc = false)
  	if allc
  		Card.find(:all, :order => 'number')
  	else
  		Card.find(:all, :order => 'number').select{|c| c.team_games.select{|tg| tg.game.round.number == round }.empty? }
  	end
  end
  
  def bracket_for_team
  
  end
  
  def save_game
  	begin
  		@game = Game.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		@game = nil
  	end
  
  	if params[:round_number].empty?
  		flash[:error] = "Round number cannot be empty."
		redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
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
		redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
		return false
	end	
  	
  	if params[:score1].to_i == params[:score2].to_i and not params[:forfeit]
  		flash[:error] = "Scores cannot be equal in a non-forfeit."
		redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
  		return false
  	end

	teams = get_teams_for_round(round.number, !@game.nil?)
	rooms = get_rooms_for_round(round.number, !@game.nil?)
	cards = get_cards_for_round(round.number, !@game.nil?)
	
	if not params[:extragame] and not (teams.include? Team.find(params[:team1]) and teams.include? Team.find(params[:team2]))
		flash[:error] = "One or both teams has already played a game this round."
		redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
		return false
	end
	
	if @tournament.tracks_rooms?  and not params[:extragame] and not rooms.include? Room.find(params[:room])
		flash[:error] = "That room has already been used during this round."
		redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
		return false
	end
	
	if @tournament.swiss? and not params[:extragame] and not (cards.include? Card.find_by_number(params[:card1]) and cards.include? Card.find_by_number(params[:card2]) )
		flash[:error] = "One or both cards has already been used during this round."
		redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
		return false
	end
	
	if @game.nil?
	  	game = round.games.build(:round => round, :tossups => params[:tossups], :extragame => params[:extragame], :overtime => params[:overtime], :playoffs => params[:playoffs], :forfeit => params[:forfeit], :play_complete => true)
  		game.room = Room.find(params[:room]) if @tournament.tracks_rooms?
	  	game.bracket = Bracket.find(params[:bracket]) if @tournament.bracketed?
	else
		game = @game
		game.update_attributes(:round => round, :tossups => params[:tossups], :extragame => params[:extragame], :overtime => params[:overtime], :playoffs => params[:playoffs], :forfeit => params[:forfeit], :play_complete => true)
		game.room = Room.find(params[:room]) if @tournament.tracks_rooms?
		game.bracket = Bracket.find(params[:bracket]) if @tournament.bracketed?
	end
    	
    	if not game.save
    		game.errors.each_full {|msg| flash[:error] = msg }
		redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
    		return false
    	end
    	
    	if @game.nil?
		tg1 = game.team_games.build(:team => Team.find(params[:team1]), :points => params[:score1], :ordering => 1)
	    	tg1.card = Card.find_by_number(params[:card1]) if @tournament.swiss?
    	
    		tg2 = game.team_games.build(:team => Team.find(params[:team2]), :points => params[:score2], :ordering => 2)
	    	tg2.card = Card.find_by_number(params[:card2]) if @tournament.swiss?
	else
		tg1 = game.team_games[0]
		tg1.update_attributes(:points => params[:score1])
		tg1.card = Card.find_by_number(params[:card1]) if @tournament.swiss?
		
		tg2 = game.team_games[1]
		tg2.update_attributes(:points => params[:score2])
		tg2.card = Card.find_by_number(params[:card2]) if @tournament.swiss?
	end
	
	if tg1.points > tg2.points
		tg1.won = true
		tg2.won = false
	else
		tg1.won = false
		tg2.won = true
	end
    		
    	if not tg1.save
    		tg1.errors.each_full {|msg| flash[:error] = msg }
    		game.destroy if @game.nil?
		redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
    		return false
    	end
    		
    	if not tg2.save
    		tg1.errors.each_full {|msg| flash[:error] = msg }
    		game.destroy if @game.nil?
		redirect_to @game.nil? ? {:action => 'index'} : {:action => 'edit_game', :id => @game.id}
    		return false
    	end
    		
    	expire_page :controller => 'statistics', :action => 'standings'
    	expire_page :controller => 'statistics', :action => 'team', :id => tg1.team.id
    	expire_page :controller => 'statistics', :action => 'team', :id => tg2.team.id
    	expire_page :controller => 'statistics', :action => 'scoreboard'
    	flash[:notice] = "Game saved."
	redirect_to @game.nil? ? {:action => 'index'} : {:action => 'status'}
  end
  
  def ignore_indivs
  	begin
  		@game = Game.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		flash[:error] = "Game not found to ignore."
  		redirect_to :action => 'index'
  		return false
  	end
  	
  	@game.ignore_indivs = true
  	@game.save
  	
  	if not @game.errors.empty?
  		@game.errors.each_full {|msg| flash[:error] = msg}
  	end
  
  	redirect_to :action => 'index'
  end
  
  def enter_indivs
  	begin
	  	@game = Game.find(params[:id])
	rescue ActiveRecord::RecordNotFound
		flash[:error] = "The requested game was not found."
		redirect_to :action => 'index'
		return false
	end
	
	if @game.ignore_indivs
		flash[:error] = "The selected game has been marked as ignored."
		redirect_to :action => 'index'
		return false
	end
	
	@teamgame1 = @game.team_games[0]
	@teamgame2 = @game.team_games[1]
	@team1 = @teamgame1.team
	@team2 = @teamgame2.team
	@types = QuestionType.find(:all, :order => 'value desc')
  end
  
  def save_indivs
  	@types = QuestionType.find(:all, :order => 'value desc')
  	
  	# Parse the input
  	
    	game = Game.find(params[:id])
    	teams = params[:team]
    	bothteams = []
    	tgs = {}
    	pgs = []
    	for index in teams.keys
      		team = game.teams.find(teams[index])
	     	team_game = game.team_games.clone.find{|tg|tg.team == team}
	     	tgs[team.id] = team_game
      		for player_line in params["teamData"][index].values
        		fields = player_line.split(",")
	        	name = fields.shift
        		player = team.players.find(:first,:conditions => ['name = ?',name]) || team.players.create(:name => name)
        		pgame = player.player_games.create(:team_game => team_game, :tossups_heard => fields.shift)
        		
        		if pgame.tossups_heard > game.tossups
        			#fail
        			flash[:error] = "Player tossups heard were greater than game tossups heard."
        			redirect_to :action => 'enter_indivs', :id => game.id
        			pgame.destroy
        			pgs.each{|pg| pg.destroy}
        			return false;
        		end
        		
        		for type in @types
        	  		line = pgame.stat_lines.create(:question_type => type, :number => fields.shift)
        		end
        		
        		if pgame.stat_lines.collect{|sl| sl.number}.sum > pgame.tossups_heard
        			#fail
        			flash[:error] = "Player answered more tossups than tossups heard."
        			redirect_to :action => 'enter_indivs', :id => game.id
        			pgame.destroy
        			pgs.each{|pg| pg.destroy}
        			return false;        			
        		end
        		
        		pgs.push pgame
      		end
      		bothteams.push team
    	end
    	
    	# Validate the input
    	
    	# tossups answered correctly by team
    	tot_tossups = {}
    	for team in bothteams
    		tot_tossups[team.id] =  pgs.clone.select{|pg| pg.player.team.id == team.id}.collect{|pg| pg.stat_lines.clone.select{|sl| sl.question_type.value > 0}.collect{|sl| sl.number}}.flatten.sum
    	end
    	
    	# tossups answered correctly and negged on by team
    	tot_ans = {}
    	for team in bothteams
    		tot_ans[team.id] = pgs.clone.select{|pg| pg.player.team.id == team.id}.collect{|pg| pg.stat_lines.clone.collect{|sl| sl.number}}.flatten.sum
	end
	 
	tot_tuh = pgs.clone.collect{|pg| pg.tossups_heard}.sum
	
	# tossup points and bonus points by team
	tups = {}
	bps = {}
	for team in bothteams
		tups[team.id] = pgs.clone.select{|pg| pg.player.team.id == team.id}.collect{|pg| pg.stat_lines.collect{|sl| sl.question_type.value * sl.number}}.flatten.sum
		bps[team.id] = tgs[team.id].points - tups[team.id]
	end
	
	if tot_tossups.values.sum > game.tossups
		# fail		
		flash[:error] = "More tossups were answered correctly than were asked."
		redirect_to :action => 'enter_indivs', :id => game.id
		pgs.each{|pg| pg.destroy}
		return false;
	end
	
	if tot_tuh > (8*game.tossups)
		#fail
		flash[:error] = "More tossups were heard by all players than the maximum possible."
		redirect_to :action => 'enter_indivs', :id => game.id
		pgs.each{|pg| pg.destroy}
		return false;
	end
	
	for team in bothteams
		if tot_ans[team.id] > game.tossups
			#fail
			flash[:error] = "More tossups were answered by the team than were asked."
			redirect_to :action => 'enter_indivs', :id => game.id
			pgs.each{|pg| pg.destroy}
			return false;
		end
		
		if tot_tossups[team.id] == 0 and bps[team.id] > 0
			#fail			
			flash[:error] = "Team has bonus points without any correct tossups."
			redirect_to :action => 'enter_indivs', :id => game.id
			pgs.each{|pg| pg.destroy}
			return false;
		elsif tot_tossups[team.id] > 0
			bppt = (bps[team.id]/tot_tossups[team.id])
			if bppt < 0.0 or bppt > 30.0
				#fail				
				flash[:error] = "Bonus points per tossup correct is out of range 0-30"
				redirect_to :action => 'enter_indivs', :id => game.id
				pgs.each{|pg| pg.destroy}
				return false;
			end
		end
		
		
	end
	
	game.team_games.each{|tg| 
		tg.update_attributes(:tossups_correct => tot_tossups[team.id], :tossup_points => tups[team.id], :bonus_points => bps[team.id])
		tg.save
	}
	    	
	game.entry_complete = true
	game.save
	expire_page :controller => 'statistics', :action => 'personal'
	flash[:notice] = "Individual standings saved."
	redirect_to :action => 'index'  
  end
  
  # Will list all entered games and link for editing
  def status
  	@rounds = Round.find(:all, :include => :games, :order => 'number')
  	
  end
  
  def edit_game
  	begin
  		@game = Game.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		flash[:error] = "Game was not found."
  		redirect_to :action => 'status'
  	end
  
  	@last_round = @game.round.number
  end
  
  def delete_game
  	begin
  		@game = Game.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		flash[:error] = "Game was not found."
  		redirect_to :action => 'status'
  	end
  	
  	@game.destroy
  	
  	expire_page :controller => 'statistics', :action => 'standings'
    	expire_page :controller => 'statistics', :action => 'team', :id => tg1.team.id
    	expire_page :controller => 'statistics', :action => 'team', :id => tg2.team.id
    	expire_page :controller => 'statistics', :action => 'scoreboard'
  	flash[:notice] = "Game was deleted successfully."
  	redirect_to :action => 'status'
  end
  
  def clear_indivs
  	begin
  		@game = Game.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		flash[:error] = "Game was not found."
  		redirect_to :action => 'status'
  	end
  	
  	@game.team_games.each do |tg|
  		tg.player_games.each do |pg|
  			pg.destroy
  		end
  	end
  	
  	@game.update_attributes :entry_complete => false
  	
  	expire_page :controller => 'statistics', :action => 'personal'
  	flash[:notice] = "Individual stats were cleared for that game."
  	redirect_to :action => 'status'
  
  end
  
end
