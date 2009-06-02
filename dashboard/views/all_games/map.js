function (doc) {
  if (doc.type && doc.type === 'game') {

    name1 = doc.team1.name || '(card ' + doc.team1.card + ')';
    name2 = doc.team2.name || '(card ' + doc.team2.card + ')';
    emit([doc.round, doc.room], [name1, name2]);
  }
}
