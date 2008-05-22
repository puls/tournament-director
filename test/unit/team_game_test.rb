require File.dirname(__FILE__) + '/../test_helper'

class TeamGameTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :team_games
  end

end
