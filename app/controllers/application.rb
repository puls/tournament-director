# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '533c664b5d376cfe5b34f14782ba8862'
  
  def load_tournament_database(tournament)
    spec = Tournament.configurations[RAILS_ENV]
    spec[:database] = tournament.database
    ActiveRecord::Base.establish_connection(spec)
    ActiveRecord::Migrator.migrate("db/migrate_data/",nil)
    Tournament.establish_connection(RAILS_ENV)
  end
  
end
