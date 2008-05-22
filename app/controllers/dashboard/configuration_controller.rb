class Dashboard::ConfigurationController < DashboardController

  before_filter :check_configuration, :except => ["new_tournament", "create_tournament"]
  before_filter :check_teams, :except => ["new_tournament", "edit_tournament", "create_tournament", "save_tournament", "edit_teams", "save_teams"]

  def index
    redirect_to :action => "edit_tournament"
  end
  
  def get_players
  	@team = Team.find(params[:id])
  	render :partial => 'players', :locals => {:thing => @team, :players => (@team.players.empty?) ? [Player.new, Player.new, Player.new, Player.new] : @team.players.sort{|a,b| a.name <=> b.name}, :years => @tournament.includes_years}
  end

  def load_tournament
    session[:tournament_id] = params['id']
    @tournament = Tournament.find(params['id'])
    load_tournament_database(@tournament)
    redirect_to :action => "edit_tournament"
  end

  def new_tournament
    render :action => "_new_tournament"
  end
  
  def create_tournament
    @tournament = Tournament.create(:name => params['name'], :database => params['database'])
    session[:tournament_id] = @tournament.id
    load_tournament_database(@tournament)
    redirect_to :action => "edit_tournament"
  end

  def edit_tournament
    @brackets = Bracket.find(:all, :order => "ordering, name")
    if @brackets.empty? then @brackets = [Bracket.new, Bracket.new] end
    @rooms = Room.find(:all, :order => "name")
    if @rooms.empty? then @rooms = [Room.new, Room.new] end
    
    @all_tournaments = Tournament.find(:all, :order => "id desc")
    @all_tournaments.delete(@tournament)
  end
  
  def save_tournament
    @tournament.update_attributes(params['tournament'])
    QuestionType.configure_for_power(@tournament.powers)
    @tournament.bracketed = false if (params['bracket_names'].nil?)
    if @tournament.bracketed?
      brackets_to_delete = Bracket.find(:all)
      for name in params['bracket_names']
        next if name.empty?
        bracket = Bracket.find_or_create_by_name(name)
        brackets_to_delete.delete(bracket)
      end
      brackets_to_delete.each {|b| b.destroy}
    end
    @tournament.bracketed = false if Bracket.count == 0
    
    @tournament.save
    flash[:notice] = "Changes saved."
    redirect_to :action => "edit_tournament"
  end
  
  def edit_schools
  	@schools = School.find :all, :order => "name"
  	
  	begin
  		@school = School.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		@school = School.new
  	end
  end
  
  def save_school
  	begin
  		sch = School.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		sch = School.new
  	end
  	sch.update_attributes(params[:school])
  	sch.save
  	flash[:notice] = "School saved."
  	redirect_to :action => "edit_schools"
  end
  
  def edit_teams
    if @tournament.nil?
      redirect_to :action => 'edit_tournaments'
    end
    
    if School.find(:all).empty?
    	redirect_to :action => 'edit_schools'
    end
    
    begin
    	@team = Team.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    	@team = Team.new
    end
  end

  def save_team
	begin
		team = Team.find(params[:id])
	rescue ActiveRecord::RecordNotFound
		team = Team.new
	end
	team.update_attributes(params[:team])
	team.save
	flash[:notice] = "Team saved."
	redirect_to :action => 'edit_teams'
  end
  
  def delete_team
  	begin
  		team = Team.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		flash[:error] = "Team not found."
  		redirect_to :action => 'edit_teams'
  	end
  	
  	team.destroy
  	flash[:notice] = "Team deleted."
  	redirect_to :action => 'edit_teams'
  end
  
  def save_players
  	team = Team.find(params[:id], :include => :players)
  	players_to_delete = team.players.dup
  	for i in 0..params[:player_names].length
  		name = params[:player_names][i]
		next if name.nil? or name.empty?
		player = team.players.find(:first, :conditions => ['name = ?', name]) || team.players.build(:name => name)
		player.year = params[:player_years][i] unless not @tournament.includes_years
		player.future_school = params[:player_schools][i]
		player.save
		players_to_delete.delete(player)
  	end
  	players_to_delete.each{|p| p.destroy }
  	flash[:notice] = "Player names saved."
  	redirect_to :action => "edit_teams"
  end

end
