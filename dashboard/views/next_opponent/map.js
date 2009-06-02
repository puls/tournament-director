function (doc) {
  if (doc.type && doc.type === 'game') {
    if (!doc.entry_complete && doc.team1.id && doc.team2.id && doc.team1.card && doc.team2.card) {
      emit([doc.round, doc.team1.id], [doc.team2.id, doc.team1.card, doc.team2.card, doc.room, doc._id, doc._rev]);
      emit([doc.round, doc.team2.id], [doc.team1.id, doc.team2.card, doc.team1.card, doc.room, doc._id, doc._rev]);
    }
  }
}
