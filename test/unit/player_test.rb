require File.dirname(__FILE__) + '/../test_helper'

class PlayerTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :players, :teams
  end
  
  def test_team_presence
  	p = Player.new(:name => "n1")
  	assert_not_valid p
  	p.team = Team.new
  	assert_valid p
  end
  
  def test_name_presence
  	p = Player.new(:team => Team.new)
  	assert_not_valid p
  end
  
  def test_name_uniqueness
  	t1 = Team.find(1)
  	t2 = Team.find(3)
  	t1.save; t2.save
  	p1 = Player.new(:team => t1, :name => "n1")
  	p2 = Player.new(:team => t2, :name => "n2")
  	p1.save; p2.save
  	p3 = Player.new(:team => t1, :name => "n2")
  	
  	assert_valid p3
  	p3.name = p1.name
  	assert_not_valid p3
  end
  
  def test_year_checks
  	p = Player.new(:team => Team.new, :name => "n1")
  	assert_valid p
  	p.year = ""
  	assert_valid p
  	p.year = "a"
  	assert_not_valid p
  	p.year = 1.5
  	assert_not_valid p
  	p.year = rand(28)
  	assert_valid p
  end
  
  def test_qpin_checks
  	p = Player.new(:team => Team.new, :name => "n1")
  	assert_valid p
  	p.qpin = ""
  	assert_valid p
  	p.qpin = "a"
  	assert_not_valid p
  	p.qpin = 1.5
  	assert_not_valid p
  	p.qpin = rand(28)
  	assert_valid p
  end

  
  def test_destroy_on_player_games
  
  end
  
  def test_destroy_on_stat_lines
  
  end
  
  def test_destroy_on_team_games
  
  end

end
