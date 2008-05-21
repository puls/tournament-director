require File.dirname(__FILE__) + '/../test_helper'

class GameTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :games, :rounds
  end
  
  def test_round_presence
  	begin
	  	rd = Round.find(:first)
	rescue ActiveRecord::RecordNotFound
		rd = Round.new
	end
  	gm = Game.new(:round => rd, :tossups => 21)
  	assert_valid(gm)
  	gm.round = nil
  	assert_not_valid(gm)
  end
  
  def test_tossups_checks
  	begin
	  	rd = Round.find(:first)
	rescue ActiveRecord::RecordNotFound
		rd = Round.new
	end
	
	gm = Game.new(:round => rd)
	assert_not_valid(gm)
	gm.tossups = ""
	assert_not_valid(gm)
	gm.tossups = "a"
	assert_not_valid(gm)
	gm.tossups = 1.5
	assert_not_valid(gm)
	gm.tossups = 21
	assert_valid(gm)
  end
  
  def test_destroy_on_team_games
  
  end
  
  def test_destroy_on_teams
  
  end
  
  def test_destroy_on_player_games
  
  end
  
end
