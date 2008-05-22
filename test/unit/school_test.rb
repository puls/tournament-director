require File.dirname(__FILE__) + '/../test_helper'

class SchoolTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :schools
  end

end
