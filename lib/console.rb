def load_tdb(t = :first)
	ApplicationController.new.load_tournament_database Tournament.find(t)
end

def load_cardfile(filename, starting_round = 1)
  file = File.new(filename)
  file.each do |line|
    fields = line.split(',')
    room_name = fields.shift
    room = Room.find_or_create_by_name(room_name)
    round_num = starting_round
    fields.each_slice(2) do |cards|
      round = Round.find_or_create_by_number(round_num)
      game = Game.new(:round => round, :room => room)
      game.team_games = [TeamGame.create(:card => cards.first, :game => game), TeamGame.create(:card => cards.last, :game => game)]
      game.save
      round_num = round_num + 1
    end
  end
end

def load_assignments(filename, for_round = 1)
  file = File.new(filename)
  file.each do |line|
    (name, city, state, initial_card, small) = line.split("\t")
    team = Team.find_or_create_by_name(name)

    schoolname = name
    if (match = name.match(/(.+)( [ABC])$/))
      schoolname = match[1]
    end
    
    school = School.find_or_create_by_name(schoolname)
    school.city = city
    school.small = !small.nil? && small.to_i == 1
    
    team.school = school
    
    team.save
    school.save
    
    tg = TeamGame.find(:first,
      :conditions => ["card = ? AND rounds.number >= ? AND team_id IS NULL", initial_card, for_round],
      :include => {:game => :round},
      :order => "rounds.number")
    
    tg.team = team
    tg.save
  end
end

def load_assignments2(filename, for_round = 15)
  file = File.new(filename)
  file.each do |line|
    (initial_card, name) = line.split("\t")
    name.strip!
    team = Team.find_by_name(name)
    
    puts "#{name} => #{team} (#{initial_card})"

    tg = TeamGame.find(:first,
      :conditions => ["card = ? AND rounds.number >= ? AND team_id IS NULL", initial_card, for_round],
      :include => {:game => :round},
      :order => "rounds.number")
      
    
    tg.team = team
    tg.save
  end
end

def load_players(filename)
  file = File.new(filename)
  file.each do |line|
    (badname, number, goodname, number2, playername, year, age, college, wearing) = line.split("\t")
    team = Team.find_by_name(goodname.strip)
    if (team.nil?)
      puts "Skipping #{playername} on #{badname}"
      next
    end
    
    college = "" if college.nil?
    
    year_number = nil
    case year
    when "Fr."
      year_number = 9
    when "So."
      year_number = 10
    when "Jr."
      year_number = 11
    when "Sr."
      year_number = 12
    end
    
    team.players.create(:name => playername.strip, :future_school => college.strip, :year => year_number)
  end
end

def load_staff(filename)
  file = File.new(filename)
  file.each do |line|
    (name, staff1, staff2) = line.split("\t")
    room = Room.find_by_name(name)
    room.staff = "#{staff1}, #{staff2}"
    room.save
  end
end

def pending_games_for_round(number)
  round = Round.find_by_number(number)
  games = round.games.find(:all, :conditions => "play_complete is null")
  games.collect do |g|
    [g.id, g.team_games.collect do |tg|
      tg.team.name
    end]
  end
end

def reset_cards_from_round(number)
  round = Round.find_by_number(number)

  round.games.each do |game|
    (tg1, tg2) = game.team_games
    
    card1 = tg1.card
    card2 = tg2.card

    bad_tgs = TeamGame.find(:all, :include => {:game => :round}, :conditions => ["rounds.number > ? AND team_id IS NOT NULL AND (card = ? OR card = ?)", round.number, card1, card2])
    bad_tgs.each do |tg|
      puts "Bad team game: #{tg.team.name} in round #{tg.game.round.number}"
      tg.team = nil
      tg.save
    end

    if tg1.points > tg2.points
      tg1.won = true
      tg2.won = false
    else
      tg1.won = false
      tg2.won = true
    end
    
    tg1.save
    tg2.save

    next_tg1 = TeamGame.find(:first,
      :conditions => ["card = ? AND rounds.number >= ? AND team_id IS NULL", [tg1.card, tg2.card].min, round.number + 1],
      :include => {:game => :round},
      :order => "rounds.number")
    unless (next_tg1.nil?)
      next_tg1.team = tg1.won ? tg1.team : tg2.team
      next_tg1.save
    end
    
    next_tg2 = TeamGame.find(:first,
      :conditions => ["card = ? AND rounds.number >= ? AND team_id IS NULL", [tg1.card, tg2.card].max, round.number + 1],
      :include => {:game => :round},
      :order => "rounds.number")
    unless (next_tg2.nil?)
      next_tg2.team = tg1.won ? tg2.team : tg1.team
      next_tg2.save
    end
    
    nil
  end
end

def reset_cache
  count = 0
  Game.find(:all).each do |game|
    (tg1, tg2) = game.team_games
    save = false
    if (tg1.points > tg2.points)
      if (tg1.won != true || tg2.won != false)
        puts "won field is wrong for #{game.description}"
        save = true
      end
      tg1.won = true
      tg2.won = false
    else
      if (tg1.won == true || tg2.won == false)
        puts "won field is wrong for #{game.description}"
        save = true
      end
      tg1.won = false
      tg2.won = true
    end
    
    if (save)
      tg1.save
      tg2.save
    end
    
    game.team_games.each do |tg|
      tossups_correct = tg.player_games.inject(0) do |sum, pg|
        sum + pg.stat_lines.inject(0) do |sum2, sl|
          sum2 + (sl.question_type.value > 0 ? sl.number : 0)
        end
      end
      if (tossups_correct != tg.tossups_correct)
        puts "#{count}: fixing tossups for #{tg.team.name} in round #{game.round.number} (#{tg.tossups_correct} => #{tossups_correct})"
        tg.tossups_correct = tossups_correct
        count = count + 1
      end
    end
  end
end

def fix_duplicate_player_games
  Player.find(:all, :include => {:player_games => {:team_game => {:game => :round}}}).each do |player|
    played_rounds = Hash.new
    player.player_games.clone.each do |pg|
      round = pg.team_game.game.round
      if (played_rounds[round.id].nil?)
        played_rounds[round.id] = pg
      else
        puts "duplicated player game for #{player.name} in round #{round.number}"
        pg.stat_lines.each {|sl|sl.destroy}
        pg.destroy
      end
    end
  end
  
  return "something else"
end
