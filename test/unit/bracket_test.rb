require File.dirname(__FILE__) + '/../test_helper'

class BracketTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  
  #fixtures :tournaments, :brackets
  
  def setup
	load_our_fixtures :tournaments, :brackets
  end
  
  def test_name_presence
  	b = Bracket.new(:name => nil)
  	assert_not_valid(b)
  end
  
  def test_name_uniqueness
  
  end
  
  def test_ordering_numericality
  
  end

end
