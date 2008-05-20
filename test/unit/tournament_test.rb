require File.dirname(__FILE__) + '/../test_helper'

class TournamentTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments
  end
  
  def test_name_presenece
  	assert_not_valid(Tournament.new(:database => "1"))
  	assert_not_valid(Tournament.new(:name => "", :database => "2"))
  	assert_not_valid(Tournament.new(:name => nil, :database => "3"))
  	assert_valid(Tournament.new(:name => "2", :database => "4"))
  end
  
  def test_name_uniqueness
  	t1 = Tournament.new(:name => 'a1', :database => "5")
  	t2 = Tournament.new(:name => 'A1', :database => "6")
  	
  	assert_valid(t1)
  	t1.save
  	assert_not_valid(t2)
  end
  
  def test_database_presence
  	assert_not_valid(Tournament.new(:name => "3"))
  	assert_not_valid(Tournament.new(:name => "4", :database => nil))
  	assert_not_valid(Tournament.new(:name => "5", :database => ""))
  end
  
  def test_database_uniqueness
  	t1 = Tournament.new(:name => "6", :database => "7")
  	t2 = Tournament.new(:name => "7", :database => "7")
  	
  	assert_valid(t1)
  	t1.save
  	assert_not_valid(t2)
  end
  
  def test_cutoff_numericality
  	assert_valid(Tournament.new(:name => "8", :database => "8"))
  	assert_valid(Tournament.new(:name => "9", :database => "9", :tuh_cutoff => nil))
  	assert_valid(Tournament.new(:name => "10", :database => "10", :tuh_cutoff => ""))
  	assert_not_valid(Tournament.new(:name => "11", :database => "11", :tuh_cutoff => "a"))
  	assert_not_valid(Tournament.new(:name => "12", :database => "12", :tuh_cutoff => 1.5))
  	assert_valid(Tournament.new(:name => "13", :database => "13", :tuh_cutoff => 42))
  end

end
