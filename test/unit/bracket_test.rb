require File.dirname(__FILE__) + '/../test_helper'

class BracketTest < ActiveSupport::TestCase
    
  def setup
	load_our_fixtures :tournaments, :brackets
  end
  
  def test_name_presence
  	b = Bracket.new(:name => nil)
  	assert_not_valid(b)
  end
  
  def test_name_uniqueness
  	b1 = Bracket.new(:name => 'The name')
  	b2 = Bracket.new(:name => 'the Name')
  	assert_valid(b1)
  	b1.save
  	assert_not_valid(b2)
  end
  
  def test_ordering_numericality
  	b1 = Bracket.new(:name => 'The name')
  	b1.ordering = nil
  	assert_valid(b1)
  	b1.ordering = "a"
  	assert_not_valid(b1)
  	b1.ordering = 1.5
  	assert_not_valid(b1)
  	b1.ordering = 100
  	assert_valid(b1)
  end
  
  def test_delete_on_games
  
  end
  
  def test_delete_on_teams
  
  end

end
