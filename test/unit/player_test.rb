require File.dirname(__FILE__) + '/../test_helper'

class PlayerTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :players
  end

end
