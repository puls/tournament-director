module.exports = lists =
  readView: "module.exports = " + ((file) ->
    start
      'headers':
        'Content-Type': 'text/csv'
        'Content-Disposition': 'attachment; filename="' + file + '"'
    teamMemberLookup = {}
    while (row = getRow())
      switch row.key.shift()
        when 'scores' then send row.key.join(',') + "\n" if file is 'scores'
        when 'teams' then send row.key.join(',') + "\n" if file is 'teams'
        when '_players' then teamMemberLookup[row.key.join ''] = row.value
        when 'indstats'
          if file is 'indstats'
            playerName = row.key[4]
            row.key[4] = teamMemberLookup[row.key[2] + playerName] ? playerName
            send row.key.join(',') + "\n"
    "").toString()

  indstats: (head, req) -> require('lists/readView') 'indstats'
  teams: (head, req) -> require('lists/readView') 'teams'
  scores: (head, req) -> require('lists/readView') 'scores'

  qbj: (head, req) ->
    start
      'headers':
        'Content-Type': 'application/vnd.quizbowl.qbj+json'
        'Content-Disposition': 'attachment; filename="tournament.qbj"'
    send '{ "version":"1.1", "objects":['
    tournament = {}
    registrations = []
    rounds = []

    player_refs = {}
    player_ref_key = (team, player) -> "#{team}: #{player}"

    while (row = getRow())
      switch row.key[1]
        when 'tournament'
          tournament =
            name: row.value.name
            type: 'Tournament'
            phases: [{
              name: "All Matches"
            }]
          if row.value.firstPlayoffRound?
            tournament.first_playoff_round = row.value.firstPlayoffRound

        when 'match'
          match =
            id: row.value._id
            type: 'Match'
            tossups_read: row.value.tossups
            overtime_tossups_read: row.value.overtimeTossups
            location: row.value.room
            serial: row.value.serial
            moderator: row.value.moderator
            scorekeeper: row.value.scorekeeper

            match_teams: for team_object in [row.value.team1, row.value.team2]
              correctTossupsWithoutBonuses = 0
              output_object =
                team:
                  $ref: "team_#{team_object.id}"
                points: team_object.points
                match_players: for player_object in team_object.players
                  output_object =
                    player:
                      $ref: player_refs[player_ref_key(team_object.name, player_object.name)]
                    tossups_heard: player_object.tossups
                    answer_counts: [
                      {answer_type:{value: 10}, number: player_object.tens}
                      {answer_type:{value: 15}, number: player_object.fifteens}
                      {answer_type:{value: -5}, number: player_object.negFives}
                    ]
                  if player_object.overtime?
                    correctTossupsWithoutBonuses += player_object.overtime.tens + player_object.overtime.fifteens
                  output_object
                lineups: for lineup_object in team_object.lineups
                  first_question: lineup_object.firstQuestion
                  reason: lineup_object.reason
                  players: for player_name in lineup_object.players
                    $ref: player_refs[player_ref_key(team_object.name, player_name)]
              if output_object.overtime_tossups_read > 0
                output_object.correctTossupsWithoutBonuses = correctTossupsWithoutBonuses
              output_object

          if row.value.questions?
            number = 0
            match.match_questions = for question_object in row.value.questions
              number += 1
              output_object =
                question_number: number
                bonus_points: question_object.bonus_points
                buzzes: []
              if question_object.neg?
                output_object.buzzes.push
                  team:
                    $ref: "team_#{question_object.neg.team_id}"
                  player:
                    $ref: player_refs[player_ref_key(question_object.neg.team_name, question_object.neg.player)]
                  result:
                    value: question_object.neg.points
              if question_object.answer?
                output_object.buzzes.push
                  team:
                    $ref: "team_#{question_object.answer.team_id}"
                  player:
                    $ref: player_refs[player_ref_key(question_object.answer.team_name, question_object.answer.player)]
                  result:
                    value: question_object.answer.points
              output_object

          while rounds.length < row.value.round
            rounds.push
              name: "Round #{rounds.length + 1}"
              matches: []

          rounds[row.value.round - 1].matches.push $ref: match.id
          send JSON.stringify(match) + ','

        when 'registration'
          registration =
            id: row.value._id
            type: 'Registration'
            name: row.value.name
            teams: for team_object in row.value.teams
              id: "team_#{team_object.id}"
              name: team_object.name
              players: for player_object in team_object.players
                output_object =
                  id: "player_#{player_object.id}"
                  name: player_object.name
                output_object.year = player_object.year if player_object.year?
                player_refs[player_ref_key(team_object.name, player_object.name)] = output_object.id
                output_object

          registrations.push $ref : registration.id
          send JSON.stringify(registration) + ','

    tournament.phases[0].rounds = rounds
    tournament.registrations = registrations
    send JSON.stringify tournament
    send ']}'
    ""
