class Dashboard::SchedulingController < DashboardController
  
  before_filter :check_configuration
  
  def index
    @rooms = Room.find(:all, :include => {:games => :team_games}, :order => "name")
    if @rooms.empty?
      @rooms = [Room.new, Room.new]
    end

    @rounds = Round.find(:all, :order => "number")
  end
  
  def set_rounds
    params['count'].to_i.times do |number|
      Round.find_or_create_by_number(number + 1)
    end
    
    flash[:notice] = "Rounds created"
    redirect_to :action => "index"
  end
  
  def save_rooms
    rooms_to_delete = Room.find(:all)
    params['room_names'].each_with_index do |name, index|
      next if name.empty?
      room = Room.find_or_create_by_name(name)
      room.staff = params['room_staffs'][index]
      room.save
      rooms_to_delete.delete(room)
    end
    rooms_to_delete.each {|r| r.destroy}
    
    flash[:notice] = "Rooms saved"
    redirect_to :action => "index"
  end
  
  
end
