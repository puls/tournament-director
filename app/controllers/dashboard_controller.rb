class DashboardController < ApplicationController

  def index
    redirect_to :controller => "/dashboard/entry"
  end

  protected
  def load_configuration
    unless session[:tournament_id].nil?
      begin
        @tournament = Tournament.find(session[:tournament_id])
      rescue ActiveRecord::RecordNotFound
        @tournament = nil
        session[:tournament_id] = nil
      end
    end
    
    if @tournament.nil?
      	@tournament = Tournament.find(:first)
      	session[:tournament_id] = @tournament.id unless @tournament.nil?
    end
    
    if @tournament.nil?
      redirect_to :controller => "/dashboard/configuration", :action => "new_tournament"
      return false
    else
      begin
      	QuestionType.find_by_value(15)
      rescue ActiveRecord::StatementInvalid
        load_tournament_database(@tournament)
      end
    end
  end

  def check_configuration
    load_configuration

    unless Team.count > 0
      redirect_to :controller => "/dashboard/configuration", :action => "edit_teams"
      return false
    end
  end


end
