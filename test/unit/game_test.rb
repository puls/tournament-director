require File.dirname(__FILE__) + '/../test_helper'

class GameTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :games
  end

end
