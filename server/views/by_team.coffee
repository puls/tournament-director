module.exports =
  map: (doc) ->
    output_teams = (team1, team2) ->
      emit [team1.id, team1.name, doc.round, 'team'], [team2.name, team1.points, team2.points, doc.tossups]
      if team1.players
        for key, player of team1.players
          emit [team1.id, team1.name, doc.round, player.name], [team2.name, player.tossups, player.fifteens, player.tens, player.negFives] if player.name

    if doc.type and doc.type is 'game' and doc.scoreEntered
      output_teams doc.team1, doc.team2
      output_teams doc.team2, doc.team1
