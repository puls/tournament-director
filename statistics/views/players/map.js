function (doc) {
  if (doc.type && doc.type === 'game' && doc.indivs_complete && doc.round < 16) {
    for each (var player in doc.team1.players) {
      if (player.name !== '') {
        emit([doc.team1.name, player.name], [doc.tossups, 0, player.tossups, player.fifteens, player.tens, player.negs, 15 * player.fifteens + 10 * player.tens - 5 * player.negs, 0, 0, 0, 1]);
      }
    }

    for each (var player in doc.team2.players) {
      if (player.name !== '') {
        emit([doc.team2.name, player.name], [doc.tossups, 0, player.tossups, player.fifteens, player.tens, player.negs, 15 * player.fifteens + 10 * player.tens - 5 * player.negs, 0, 0, 0, 1]);
      }
    }
  }
}