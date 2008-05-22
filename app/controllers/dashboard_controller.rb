class DashboardController < ApplicationController
  
  def index
    redirect_to :controller => "/dashboard/entry"
  end

  protected
  def check_configuration
    load_configuration

    if @tournament.nil?
      redirect_to :controller => "/dashboard/configuration", :action => "new_tournament"
      return false
    end
  end
  
  def check_teams
    unless Team.count > 0
      redirect_to :controller => "/dashboard/configuration", :action => "edit_teams"
      return false
    end
  end


end
