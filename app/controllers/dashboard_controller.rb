class DashboardController < ApplicationController
  
  def index
    redirect_to :controller => "/dashboard/entry"
  end
  
  protected
  def load_configuration
    if (session[:tournament_id].nil?)
      @tournament = Tournament.find(:first)
      session[:tournament_id] = @tournament.id unless @tournament.nil?
    else
      begin
        @tournament = Tournament.find(session[:tournament_id])
      rescue ActiveRecord::RecordNotFound
        @tournament = nil
        session[:tournament_id] = nil
      end
    end
  end
  
  def check_configuration
    unless (Tournament.count > 0)
      redirect_to :controller => "/dashboard/configuration", :action => "edit_tournaments"
      return false
    end
    
    load_configuration
    
    unless (Team.count > 0)
      redirect_to :controller => "/dashboard/configuration", :action => "edit_teams"
      return false
    end
  end
  

end
