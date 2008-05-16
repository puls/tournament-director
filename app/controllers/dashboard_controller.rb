class DashboardController < ApplicationController

  def index
    redirect_to :controller => "/dashboard/entry"
  end

  protected
  def load_configuration
    if session[:tournament_id].nil?
      if session[:new_tournament]
        @tournament = Tournament.new(:name => "New Tournament")
        @tournament.save
        session[:tournament_id] = @tournament.id
        session[:new_tournament] = nil
      else
      	@tournament = Tournament.find(:first)
      	session[:tournament_id] = @tournament.id unless @tournament.nil?
      end
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
    load_configuration

    if @tournament.nil?
      redirect_to :controller => "/dashboard/configuration", :action => "new_tournament"
      return false
    end

    unless @tournament.teams.count > 0
      redirect_to :controller => "/dashboard/configuration", :action => "edit_teams"
      return false
    end
  end


end
