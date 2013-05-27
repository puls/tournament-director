module.exports =

  map: (doc) ->
    if doc.type and doc.type is "game" and doc.playersEntered and doc.round < 17
      for player in doc.team1.players
        emit [ doc.team1.name, player.name ], [ doc.tossups, 0, player.tossups, player.fifteens, player.tens, player.negFives, 15 * player.fifteens + 10 * player.tens - 5 * player.negFives, 0, 0, 0, 1 ]  if player.name isnt ""
      for player in doc.team2.players
        emit [ doc.team2.name, player.name ], [ doc.tossups, 0, player.tossups, player.fifteens, player.tens, player.negFives, 15 * player.fifteens + 10 * player.tens - 5 * player.negFives, 0, 0, 0, 1 ]  if player.name isnt ""

  reduce: (keys, values, rereduce) ->
    output = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
    values.forEach (row) ->
      i = 0

      while i < row.length
        output[i] += row[i]
        i++

    output[1] = output[10] * output[2] / output[0]
    output[7] = 20 * output[6] / output[2]
    output[8] = (if output[5] is 0 then 0 else (output[3] + output[4]) / output[5])
    output[9] = 20 * output[5] / output[2]
    output
