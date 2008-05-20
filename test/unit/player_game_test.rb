require File.dirname(__FILE__) + '/../test_helper'

class PlayerGameTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :player_games
  end

end
