function (doc) {
  if (doc.type && doc.type === 'game') {

    if (!doc.entry_complete) {
      emit(doc.team1.card, [doc.round, doc]);
      emit(doc.team2.card, [doc.round, doc]);
    }
  }
}
