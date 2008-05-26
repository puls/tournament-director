class Welcome::ControlsController < WelcomeController

  before_filter :load_configuration
  before_filter :get_school_lists, :except => [:toggle_check_in, :toggle_roster, :toggle_paid]
  layout 'dashboard'

  def index
  end

  def toggle_check_in
      begin
	school = School.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "School was not found."
        redirect_to :action => 'index'
      end

      if school.update_attributes(:checked_in => !school.checked_in?)
        flash[:notice] = "#{school.name} checked in."
      else
        flash[:error] = "#{school.name} not checked in."
      end

      redirect_to :action => 'index'
  end

  def toggle_roster
      begin
	school = School.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "School was not found."
        redirect_to :action => 'index'
      end

      if school.update_attributes(:checked_roster => !school.checked_roster?)
        flash[:notice] = "#{school.name} checked roster."
      else
        flash[:error] = "#{school.name} not checked roster."
      end

      redirect_to :action => 'index'
  end

  def toggle_paid
      begin
	school = School.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "School was not found."
        redirect_to :action => 'index'
      end

      if school.update_attributes(:paid => !school.paid?)
        flash[:notice] = "#{school.name} paid."
      else
        flash[:error] = "#{school.name} paid."
      end

      redirect_to :action => 'index'
  end


end
