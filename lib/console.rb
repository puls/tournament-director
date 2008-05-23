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