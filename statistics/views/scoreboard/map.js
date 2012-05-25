function (doc) {
  if (doc.type && doc.type === 'game' && doc.entry_complete) {
    emit([doc.round, doc.team1.id, doc.team1.name, doc.team1.points, doc.team2.id, doc.team2.name, doc.team2.points], null);
  }
}