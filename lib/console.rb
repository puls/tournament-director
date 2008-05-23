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
