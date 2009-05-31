function (doc) {
  if (doc.type && doc.type === 'game' && doc.entry_complete) {
    
    emit([doc.team1.id, doc.team1.name, doc.round, 'team'], [doc.round, doc.team2.name, doc.team1.points, doc.team2.points, doc.tossups]);
    
    if (doc.team1.players) {
      for each (var player in doc.team1.players) {
        if (player.name !== '') {
          emit([doc.team1.id, doc.team1.name, doc.round, player.name], [doc.round, doc.team2.name, player.tossups, player.fifteens, player.tens, player.negs]);
        }
      }
    }

    emit([doc.team2.id, doc.team2.name, doc.round, 'team'], [doc.round, doc.team1.name, doc.team2.points, doc.team1.points, doc.tossups]);
    
    if (doc.team2.players) {
      for each (var player in doc.team2.players) {
        if (player.name !== '') {
          emit([doc.team2.id, doc.team2.name, doc.round, player.name], [doc.round, doc.team1.name, player.tossups, player.fifteens, player.tens, player.negs]);
        }
      }
    }

  }
}