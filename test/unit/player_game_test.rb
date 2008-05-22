require File.dirname(__FILE__) + '/../test_helper'

class PlayerGameTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :player_games, :players, :team_games
  end
  
  def test_player_presence
  	pg = PlayerGame.new(:team_game => TeamGame.new, :tossups_heard => 20)
  	assert_not_valid(pg)
  	pg.player = Player.new
  	assert_valid(pg)
  end
  
  def test_team_game_presence
  	pg = PlayerGame.new(:player => Player.new, :tossups_heard => 20)
  	assert_not_valid pg
  	pg.team_game = TeamGame.new
  	assert_valid pg
  end
  
  def test_tossups_heard_checks
  	pg = PlayerGame.new(:player => Player.new, :team_game => TeamGame.new)
  	assert_not_valid pg
  	pg.tossups_heard = ""
  	assert_not_valid pg
  	pg.tossups_heard = "a"
  	assert_not_valid pg
  	pg.tossups_heard = 1.5
  	assert_not_valid pg
  	pg.tossups_heard = rand(28)
  	assert_valid pg
  end
  
  def test_destroy_on_stat_lines
  
  end

end
