module.exports = () ->
  done = @async()
  request = require 'request'
  faker = require 'faker2'
  to_id = require './to_id'

  database = require './database'

  round_count = 15
  team_count = 240
  games_per_round = 80
  all_teams = {}
  team_ids = []
  schools = []
  games = []
  rooms = faker.definitions.street_suffix()

  to_id = (name) -> name.toLowerCase().replace /[^a-z0-9]+/g,'_'

  rand = (max) -> Math.floor(Math.random() * max)

  fisherYates = (arr) ->
    i = arr.length
    if i is 0 then return false

    while --i
      j = rand(i + 1)
      [arr[i], arr[j]] = [arr[j], arr[i]]

  tournament_id = rand 1000000
  tournament =
    type: 'tournament'
    name: 'Test Tournament'
    id: tournament_id
    _id: 'tournament'

  while team_count > 0
    teams_from_school = 1 + rand 5
    city = faker.Address.city()
    school =
      tournament: 'tournament'
      tournament_id: tournament_id
      id: rand 1000000
      type: 'school'
      name: "#{city} High School"
      city: "#{city}, #{faker.Address.usState()}"
      small: teams_from_school == 1 && rand(5) > 3
      teams: []
    school._id = "school_#{to_id school.name}"
    schools.push school
    for num in [1..teams_from_school]
      break if team_count < 1
      team_name = if teams_from_school == 1 then school.name else "#{school.name} #{['A','B','C','D','E'][num - 1]}"
      team = {name:team_name, players:[], id: rand(1000000), '_id': to_id team_name}
      school.teams.push team
      team_ids.push team.id
      all_teams[team.id] = team
      for i in [0..3]
        player =
          name: "#{faker.Name.firstName()} #{faker.Name.lastName()}"
          year: [9..12][rand 4]
          id: rand 1000000
        team.players.push player
      team_count--

  for num in [1..round_count]
    fisherYates team_ids
    fisherYates rooms
    for i in [1..games_per_round]
      console.log "room is #{rooms[i - 1]}"
      game =
        type: 'game'
        tournament: 'tournament'
        round: num
        scoreEntered: true
        playersEntered: true
        serial: "#{num}-#{i}"
        room: rooms[i - 1]
        tossups: [17..24][rand 8]
        team1:
          id: team_ids[2 * i]
          points: 5 * rand 140
          players: []
        team2:
          id: team_ids[2 * i + 1]
          points: 5 * rand 140
          players: []
      ['team1', 'team2'].forEach (team_key) ->
        game[team_key].name = all_teams[game[team_key].id].name
        game[team_key]._id = all_teams[game[team_key].id]._id
        for own player_id, player of all_teams[game[team_key].id].players
          game[team_key].players.push
            id: player_id
            name: player.name
            tossups: game.tossups
            fifteens: [0..1][rand 2]
            tens: [0..3][rand 4]
            negFives: [0..3][rand 4]

      game._id = "game_#{game.round}_#{game.team1._id}_#{game.team2._id}"
      games.push game

  docs = schools.concat games
  docs.push tournament
  request.del database, (error, response, body) ->
    request.put database, (error, response, body) ->
      request
        url: "#{database}/_bulk_docs"
        method: 'POST'
        json: {docs: docs}
        (error, response, body) -> done()
