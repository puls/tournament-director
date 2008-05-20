require File.dirname(__FILE__) + '/../test_helper'

class StatLineTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :stat_lines
  end

end
