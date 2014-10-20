module.exports = ->
  done = @async()
  request = require 'request'
  faker = require 'faker'
  to_id = require './to_id'

  database = require './database'
  csv = require 'csv'

  cities = []
  csv().from.path(__dirname + '/cities.csv')
    .on('record', (row) -> cities.push row)
    .on('end', (count) -> generate())

  generate = ->
    round_count = 26
    team_count = 256
    games_per_round = 96
    all_teams = {}
    team_ids = []
    schools = []
    games = []
    rooms = faker.random.street_suffix()[0...games_per_round]

    to_id = (name) -> name.toLowerCase().replace /[^a-z0-9]+/g, '_'

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
      teams_from_school = 1# + rand 5
      city = cities[rand cities.length]
      school =
        tournament: 'tournament'
        tournament_id: tournament_id
        id: rand 1000000
        type: 'school'
        name: "#{city[2]}"
        city: "#{city[2]}, #{city[1]}"
        small: teams_from_school == 1 && rand(5) > 3
        teams: []
      school._id = "school_#{to_id school.name}"
      schools.push school
      for num in [1..teams_from_school]
        break if team_count < 1
        team_name = if teams_from_school == 1 then school.name else "#{school.name} #{['A','B','C','D','E'][num - 1]}"
        team = {name: team_name, players: [], id: rand(1000000), '_id': to_id team_name}
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
      if team_count >= 3 * games_per_round
        if num % 3 == 1
          fisherYates team_ids
          effectiveTeamIDs = team_ids[0...games_per_round * 2]
        else if num % 3 == 2
          effectiveTeamIDs = team_ids[games_per_round...games_per_round * 3]
        else
          effectiveTeamIDs = team_ids.filter (element, index) -> index < games_per_round || index >= 2 * games_per_round
      else
        effectiveTeamIDs = team_ids
      fisherYates effectiveTeamIDs
      fisherYates rooms
      for gameIndex in [0...games_per_round]
        game =
          type: 'game'
          tournament: 'tournament'
          round: num
          scoreEntered: true
          playersEntered: true
          serial: "#{num}-#{gameIndex + 1}"
          room: rooms[gameIndex]
          tossups: [17..24][rand 8]
          overtimeTossups: 0
          team1:
            id: effectiveTeamIDs[2 * gameIndex]
            points: 0
            players: []
          team2:
            id: effectiveTeamIDs[2 * gameIndex + 1]
            points: 0
            players: []
        ['team1', 'team2'].forEach (team_key) ->
          game[team_key].name = all_teams[game[team_key].id].name
          game[team_key]._id = all_teams[game[team_key].id]._id
          for own player_id, player of all_teams[game[team_key].id].players
            player =
              id: player_id
              name: player.name
              tossups: game.tossups
              fifteens: 0
              tens: 0
              negFives: 0
            game[team_key].players.push player

        game._id = "game_#{game.round}_#{game.team1._id}_#{game.team2._id}"

        allPlayers = (cb) ->
          for player in game.team1.players
            cb player
          for player in game.team2.players
            cb player

        playTossup = (incrementOvertime = false) ->
          hasNeg = (rand(4) == 1)
          hasFifteen = (rand(5) == 1)
          answerTeam = if rand(2) == 1 then 'team1' else 'team2'

          if hasNeg
            negPlayer = rand 4
            game[answerTeam].players[negPlayer].negFives += 1
            game[answerTeam].players[negPlayer].overtime.negFives += 1 if incrementOvertime
            game[answerTeam].points -= 5
            answerTeam = if answerTeam is 'team1' then 'team2' else 'team1'

          return false if rand(10) == 1 # Question went dead

          answerPlayer = rand 4

          if hasFifteen
            game[answerTeam].players[answerPlayer].fifteens += 1
            game[answerTeam].players[answerPlayer].overtime.fifteens += 1 if incrementOvertime
            game[answerTeam].points += 15
          else
            game[answerTeam].players[answerPlayer].tens += 1
            game[answerTeam].players[answerPlayer].overtime.tens += 1 if incrementOvertime
            game[answerTeam].points += 10

          answerTeam

        for question in [1..game.tossups]
          answerTeam = playTossup false
          game[answerTeam].points += [0, 10, 20, 30][rand 4] if answerTeam

        if game.team1.points == game.team2.points

          allPlayers (player) ->
            player.overtime =
              tossups: 0
              fifteens: 0
              tens: 0
              negFives: 0

          while game.team1.points == game.team2.points or game.overtimeTossups < 3 # Tied, play overtime
            playTossup true
            game.overtimeTossups += 1

          game.tossups += game.overtimeTossups
          allPlayers (player) ->
            player.tossups += game.overtimeTossups
            player.overtime.tossups += game.overtimeTossups

          console.log "Played overtime for #{game.overtimeTossups} tossups in #{game._id}"

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
