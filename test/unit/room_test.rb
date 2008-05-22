require File.dirname(__FILE__) + '/../test_helper'

class RoomTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :rooms
  end

end
