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

def flip(game_id)
  game = Game.find(game_id)
  (tg1, tg2) = game.team_games
  points = tg2.points
  tg2.points = tg1.points
  tg1.points = points
  tg1.save
  tg2.save
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
    next_tg1.team = tg1.won ? tg1.team : tg2.team
    next_tg1.save
    
    next_tg2 = TeamGame.find(:first,
      :conditions => ["card = ? AND rounds.number >= ? AND team_id IS NULL", [tg1.card, tg2.card].max, round.number + 1],
      :include => {:game => :round},
      :order => "rounds.number")
    next_tg2.team = tg1.won ? tg2.team : tg1.team
    next_tg2.save
    
    nil
  end
end
