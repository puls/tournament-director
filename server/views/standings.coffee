module.exports =

  map: (doc) ->
    if doc.type and doc.type is 'game' and doc.scoreEntered# and doc.round isnt 8
      team1win = (doc.team1.points > doc.team2.points)
      team1points = (if doc.team1.points is 1 then 0 else doc.team1.points)
      team2points = (if doc.team2.points is 1 then 0 else doc.team2.points)
      tossups1 = 0
      tossups2 = 0
      bonuspoints1 = doc.team1.points
      bonuspoints2 = doc.team2.points
      for key, player of doc.team1.players
        tossups1 += player.fifteens + player.tens
        bonuspoints1 -= (15 * player.fifteens + 10 * player.tens - 5 * player.negFives)
      for key, player of doc.team2.players
        tossups2 += player.fifteens + player.tens
        bonuspoints2 -= (15 * player.fifteens + 10 * player.tens - 5 * player.negFives)
      emit [doc.team1.name, doc.team1.id, doc.bracket], [(if team1win then 1 else 0), (if team1win then 0 else 1), 0, team1points, 0, team2points, 0, doc.tossups, 0, tossups1, bonuspoints1, 0]
      emit [doc.team2.name, doc.team2.id, doc.bracket], [(if team1win then 0 else 1), (if team1win then 1 else 0), 0, team2points, 0, team1points, 0, doc.tossups, 0, tossups2, bonuspoints2, 0]

  reduce: (keys, values, rereduce) ->
    output = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    for row in values
      for value, index in row
        output[index] += value

    games = output[0] + output[1]
    output[2] = output[0] / games
    output[4] = output[3] / games
    output[6] = output[5] / games
    output[8] = 20 * output[3] / output[7]
    output[11] = (if output[9] > 0 then output[10] / output[9] else 0)
    output
