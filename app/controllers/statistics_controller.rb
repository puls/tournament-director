class StatisticsController < ApplicationController

  caches_page :standings,:personal,:team,:ppb,:scoreboard,:aggregate

  def index
    redirect_to :action => "standings"
  end
  
  def standings
    
  end

end
