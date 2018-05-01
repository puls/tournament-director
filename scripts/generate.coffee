request = require 'request'
database = require './database'

generateEverythingWithSchools = (existingTournament, existingSchools, done) ->
  faker = require 'faker'
  to_id = require './to_id'

  csv_parse = require 'csv-parse'
  fs = require 'fs'

  cities = []
  
  parser = csv_parse()
  parser.on('readable', -> cities.push record while record = parser.read())
  parser.on('finish', -> generate())
  parser.write(fs.readFileSync(__dirname + '/cities.csv', 'utf8'))
  parser.end()

  generate = ->
    round_count = 15
    team_count = 66
    games_per_round = 22

    schools = existingSchools
    all_teams = {}
    team_ids = []

    for school in schools
      for team in school.teams
        all_teams[team.id] = team
        team_ids.push team.id

    games = []
    rooms = [0...games_per_round]

    to_id = (name) -> name.toLowerCase().replace /[^a-z0-9]+/g, '_'

    rand = (max) -> Math.floor(Math.random() * max)

    fisherYates = (arr) ->
      i = arr.length
      if i is 0 then return false

      while --i
        j = rand(i + 1)
        [arr[i], arr[j]] = [arr[j], arr[i]]

    tournament_id = rand 1000000
    tournament = existingTournament ?
      type: 'tournament'
      name: 'Test Tournament'
      id: tournament_id
      _id: 'tournament'

    teams_to_generate = team_count - team_ids.length
    while teams_to_generate > 0
      teams_from_school = 1 + rand 5
      city = cities[rand cities.length]
      school =
        tournament: 'tournament'
        tournament_id: tournament_id
        id: rand 1000000
        type: 'school'
        name: "#{city[2]}"
        location: "#{city[2]}, #{city[1]}"
        small: teams_from_school == 1 && rand(5) > 3
        teams: []
      school._id = "school_#{to_id school.name}"
      schools.push school
      for num in [1..teams_from_school]
        break if teams_to_generate < 1
        team_name = if teams_from_school == 1 then school.name else "#{school.name} #{['A','B','C','D','E'][num - 1]}"
        team = {name: team_name, players: [], id: rand(1000000), '_id': to_id team_name}
        school.teams.push team
        team_ids.push team.id
        all_teams[team.id] = team
        players_from_team = 4 + rand 3
        for i in [0..players_from_team]
          player =
            name: "#{faker.name.firstName()} #{faker.name.lastName()}"
            year: [9..12][rand 4]
            id: rand 1000000
          team.players.push player
        teams_to_generate--

    for num in [1..round_count]
      if team_count >= 3 * games_per_round
        if num % 3 == 1
          fisherYates team_ids
          console.log "First third of teams"
          effectiveTeamIDs = team_ids[0...games_per_round * 2]
        else if num % 3 == 2
          console.log "Second third of teams"
          effectiveTeamIDs = team_ids[games_per_round...games_per_round * 3]
        else
          console.log "Third third of teams"
          effectiveTeamIDs = team_ids.filter (element, index) -> index < games_per_round || index >= 2 * games_per_round
      else
        console.log "Using all teams"
        effectiveTeamIDs = team_ids
      fisherYates effectiveTeamIDs
      fisherYates rooms
      for gameIndex in [0...games_per_round]
        console.log "Game index #{gameIndex}"
        game =
          type: 'game'
          tournament: 'tournament'
          round: num
          event: 'Test Tournament'
          packet: num
          moderator: 'Q. Q*bert Hentzel'
          scorekeeper: 'Skip Jumppes'
          scoreEntered: true
          playersEntered: true
          serial: "#{num}-#{gameIndex + 1}"
          room: "Room #{rooms[gameIndex]}"
          tossups: [17..24][rand 8]
          overtimeTossups: 0
          questions: []
          overtimeQuestions: []
          team1:
            id: effectiveTeamIDs[2 * gameIndex]
            points: 0
            players: []
            lineups: []
          team2:
            id: effectiveTeamIDs[2 * gameIndex + 1]
            points: 0
            players: []
            lineups: []
        ['team1', 'team2'].forEach (team_key) ->
          game[team_key].name = all_teams[game[team_key].id].name
          game[team_key]._id = all_teams[game[team_key].id]._id
          for own player_id, player of all_teams[game[team_key].id].players
            player =
              id: player_id
              name: player.name
              tossups: 0
              fifteens: 0
              tens: 0
              negFives: 0
            game[team_key].players.push player

        game._id = "game_#{game.round}_#{game.team1._id}_#{game.team2._id}"

        game.team1.lineups = [{firstQuestion: 1, reason: 'initial', players: game.team1.players[0..3].map (player) -> player.name}]
        game.team2.lineups = [{firstQuestion: 1, reason: 'initial', players: game.team2.players[0..3].map (player) -> player.name}]

        allPlayers = (cb) ->
          for player in game.team1.players
            cb player
          for player in game.team2.players
            cb player

        insertHalf = ->
          fisherYates game.team1.players
          fisherYates game.team2.players
          game.team1.lineups.push {firstQuestion: game.questions.length + 1, reason: 'halftime', players: game.team1.players[0..3].map (player) -> player.name}
          game.team2.lineups.push {firstQuestion: game.questions.length + 1, reason: 'halftime', players: game.team2.players[0..3].map (player) -> player.name}

        insertTimeout = (isTeam1) ->
          [team1Reason, team2Reason] = if isTeam1 then ['own_timeout', 'other_timeout'] else ['other_timeout', 'own_timeout']
          fisherYates game.team1.players
          fisherYates game.team2.players
          game.team1.lineups.push {firstQuestion: game.questions.length + 1, reason: team1Reason, players: game.team1.players[0..3].map (player) -> player.name}
          game.team2.lineups.push {firstQuestion: game.questions.length + 1, reason: team2Reason, players: game.team2.players[0..3].map (player) -> player.name}

        playTossup = (incrementOvertime = false) ->
          lineups =
            team1: game.team1.lineups[game.team1.lineups.length - 1].players
            team2: game.team2.lineups[game.team2.lineups.length - 1].players
          question =
            bonus_points: 0

          for teamIndex in ['team1', 'team2']
            for playerName in lineups[teamIndex]
              playerIndex = game[teamIndex].players.map((player) -> player.name).indexOf playerName
              game[teamIndex].players[playerIndex].tossups += 1
              if incrementOvertime
                game[teamIndex].players[playerIndex].overtime.tossups += 1

          if incrementOvertime
            game.overtimeQuestions.push question
          else
            game.questions.push question

          hasNeg = (rand(4) == 1)
          hasFifteen = (rand(5) == 1)
          answerTeam = if rand(2) == 1 then 'team1' else 'team2'

          if hasNeg
            negPlayerName = lineups[answerTeam][rand 4]
            negPlayer = game[answerTeam].players.map((player) -> player.name).indexOf negPlayerName
            game[answerTeam].players[negPlayer].negFives += 1
            game[answerTeam].players[negPlayer].overtime.negFives += 1 if incrementOvertime
            game[answerTeam].points -= 5
            question.neg =
              team_id: game[answerTeam].id
              team_name: game[answerTeam].name
              points: -5
              player: game[answerTeam].players[negPlayer].name
            answerTeam = if answerTeam is 'team1' then 'team2' else 'team1'

          return false if rand(10) == 1 # Question went dead

          answerPlayerName = lineups[answerTeam][rand 4]
          answerPlayer = game[answerTeam].players.map((player) -> player.name).indexOf answerPlayerName

          question.answer =
            team_id: game[answerTeam].id
            team_name: game[answerTeam].name
            player: game[answerTeam].players[answerPlayer].name

          if hasFifteen
            game[answerTeam].players[answerPlayer].fifteens += 1
            game[answerTeam].players[answerPlayer].overtime.fifteens += 1 if incrementOvertime
            game[answerTeam].points += 15
            question.answer.points = 15
          else
            game[answerTeam].players[answerPlayer].tens += 1
            game[answerTeam].players[answerPlayer].overtime.tens += 1 if incrementOvertime
            game[answerTeam].points += 10
            question.answer.points = 10

          if !incrementOvertime
            bonusPoints = [0, 10, 20, 30][rand 4]
            game[answerTeam].points += bonusPoints
            question.bonus_points = bonusPoints

          answerTeam

        halftimeTossup = Math.floor(game.tossups / 2)
        timeoutTossup = rand game.tossups * 2
        if timeoutTossup == halftimeTossup
          timeoutTossup = -1
        for question in [1..game.tossups]
          answerTeam = playTossup false
          insertHalf() if question == halftimeTossup
          insertTimeout(0 == rand 2) if question == timeoutTossup

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

          console.log "Played overtime for #{game.overtimeTossups} tossups in #{game._id}"

        games.push game

    console.log "Generated #{games.length} games"
    docs = schools.concat games
    docs.push tournament
    request.del database, (error, response, body) ->
      request.put database, (error, response, body) ->
        request
          url: "#{database}/_bulk_docs"
          method: 'POST'
          json: {docs: docs}
          (error, response, body) -> done()

module.exports = 
  generateGames: ->
    done = @async()
    request.get "#{database}/tournament", (error, response, body) =>
      tournament = JSON.parse body
      request
        url: "#{database}/_design/app/_view/by_type?key=[\"tournament\", \"school\"]&include_docs=true"
        method: 'GET'
        (error, response, body) =>
          docs = JSON.parse body
          schools = docs.rows.map (row) -> row.doc
          generateEverythingWithSchools tournament, schools, done
  
  generateEverything: ->
    done = @async()
    generateEverythingWithSchools null, [], done

