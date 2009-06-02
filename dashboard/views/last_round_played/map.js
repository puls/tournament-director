function (doc) {
  if (doc.type) {
    if (doc.type === 'school') {
      for (var team_id in doc.teams) {
        emit(team_id, [0, 0]);
      }
    } else if (doc.type === 'game' && doc.entry_complete) {
      if (doc.team1.id) {
        emit(doc.team1.id, [doc.round, 0]);
      }
      if (doc.team2.id) {
        emit(doc.team2.id, [doc.round, 0]);
      }
    }
  }
}
