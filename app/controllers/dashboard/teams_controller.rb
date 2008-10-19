class Dashboard::TeamsController < DashboardController
  
  before_filter :check_configuration

  def index
    @schools = School.find(:all, :include => {:teams => :players}, :order => "schools.name")
  end
  
  def add_school
    school = School.find_or_create_by_name(params[:school_name])
    school.update_attributes(:city => params[:school_city], :small => params[:school_small])
    flash[:notice] = "#{school.name} created."
    redirect_to :action => "index"
  end
  
  def add_team
    school = School.find(params[:school_id])
    team = school.teams.create(:name => params[:team_name])
    flash[:notice] = "#{team.name} created."
    redirect_to :action => "index"
  end
  
  def players
    @school = School.find(params[:id], :include => {:teams => :players})
  end
  
  def save_players
    school = School.find(params[:id], :include => {:teams => :players})
    school.teams.each do |team|
      players_to_delete = team.players.clone
      params["team#{team.id}_names"].each_with_index do |name, index|
        next if name.empty?
        player = Player.find_or_create_by_name_and_team_id(name, team.id)
        players_to_delete.delete(player)
        if $tournament.includes_years? then
          player.year = params["team#{team.id}_years"][index]
        end
        player.future_school = params["team#{team.id}_future_schools"][index]
        player.save
      end
      players_to_delete.each {|p| p.destroy}
    end
    
    flash[:notice] = "Players for #{school.name} saved."
    redirect_to :action => "index"
  end
  
end
