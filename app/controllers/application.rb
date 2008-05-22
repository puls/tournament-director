# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '533c664b5d376cfe5b34f14782ba8862'
  
  def load_tournament_database(tournament)
    spec = Tournament.configurations[RAILS_ENV]
    new_spec = spec.clone
    new_spec["database"] = tournament.database
    ActiveRecord::Base.establish_connection(new_spec)
    ActiveRecord::Migrator.migrate("db/migrate_data/",nil)
    Tournament.establish_connection(RAILS_ENV)
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
      	@tournament = Tournament.find(:first, :order => 'id desc')
      	session[:tournament_id] = @tournament.id unless @tournament.nil?
    end
    
    unless @tournament.nil?
      begin
      	QuestionType.find_by_value(10)
        #@tournament.power = !QuestionType.find_by_value(15).nil?
      rescue ActiveRecord::StatementInvalid
        load_tournament_database(@tournament)
      end
    end
  end
  
end
