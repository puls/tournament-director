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
    send '{ "version":"0.5", "objects":['
    tournament = {}
    matches = []
    registrations = []
    while (row = getRow())
      switch row.key.shift()
        when 'tournament'
          tournament =
            name: row.value.name
            type: 'Tournament'
          if row.value.firstPlayoffRound?
            tournament.first_playoff_round = row.value.firstPlayoffRound

        when 'match'
          match =
            id: row.value._id
            round: row.value.round
            type: 'Match'
            tossups: row.value.tossups
            overtimeTossups: row.value.overtimeTossups
            location: row.value.room
            forfeit: row.value.tossups == 0
            serial: row.value.serial
            match_teams: for team_object in [row.value.team1, row.value.team2]
              team:
                $ref: "team_#{team_object.id}"
              points: team_object.points
              match_players: for player_object in team_object.players
                player:
                  name: player_object.name
                tossups_heard: player_object.tossups
                answer_counts: [
                  {value: 10, number: player_object.tens}
                  {value: 15, number: player_object.fifteens}
                  {value: -5, number: player_object.negFives}
                ]


          matches.push $ref: match.id
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
                id: "player_#{player_object.id}"
                name: player_object.name
                year: player_object.year

          registrations.push $ref : registration.id
          send JSON.stringify(registration) + ','

    tournament.matches = matches
    tournament.registrations = registrations
    send JSON.stringify tournament
    send ']}'
    ""


