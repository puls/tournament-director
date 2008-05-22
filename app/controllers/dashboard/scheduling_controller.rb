class Dashboard::SchedulingController < DashboardController
  
  def index
    @rooms = Room.find(:all, :include => ["rounds", {"games" => "team_games"}])
    if @rooms.empty?
      @rooms = [Room.new, Room.new]
    end

    @rounds = Round.find(:all, :order => "number")
  end
  
end
