module.exports =
  map: (doc) ->
    to_id = (name) -> name.toLowerCase().replace /[^a-z0-9]+/g, '_'
    if doc.type
      if doc.type is 'game' and doc.playersEntered
        emit ['scores', doc.bracket, doc.round, to_id(doc.team1.name), to_id(doc.team2.name), doc.team1.points, doc.team2.points, doc.tossups], null
        for player in doc.team1.players
          emit ['indstats', doc.bracket, doc.round, to_id(doc.team1.name), to_id(doc.team2.name), player.name, doc.tossups, player.tossups, player.fifteens, player.tens, player.negFives], null if player.name
        for player in doc.team2.players
          emit ['indstats', doc.bracket, doc.round, to_id(doc.team2.name), to_id(doc.team1.name), player.name, doc.tossups, player.tossups, player.fifteens, player.tens, player.negFives], null if player.name
      if doc.type is 'school'
        for team in doc.teams
          if team.id?
            emit ['teams', to_id(team.name), "#{team.name} team_id:#{team.id}", doc.name, doc.city, doc.small || false], null
          else
            emit ['teams', to_id(team.name), team.name, doc.name, doc.city, doc.small || false], null
          for player in team.players
            if player.id?
              emit ['_players', to_id(team.name), player.name], "#{player.name} team_member_id:#{player.id}"
