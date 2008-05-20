require File.dirname(__FILE__) + '/../test_helper'

class RoundTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :rounds
  end

end
