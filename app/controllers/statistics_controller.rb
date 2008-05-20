class StatisticsController < ApplicationController

  caches_page :standings,:personal,:team,:ppb,:scoreboard,:aggregate
  before_filter :load_configuration

  def index
    redirect_to :action => "standings"
  end
  
  def standings
    
  end
  
  def scoreboard
  	@rounds = Round.find(:all, :order => 'number desc')
  end

end
