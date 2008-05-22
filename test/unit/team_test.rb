require File.dirname(__FILE__) + '/../test_helper'

class TeamTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :teams
  end

end
