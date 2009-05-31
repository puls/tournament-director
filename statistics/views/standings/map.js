function (doc) {
  if (doc.type && doc.type === 'game' && doc.entry_complete) {
    var team1win = (doc.team1.points > doc.team2.points);
    var team1points = (doc.team1.points == 1 ? 0 : doc.team1.points);
    var team2points = (doc.team2.points == 1 ? 0 : doc.team2.points);
    emit([doc.team1.name, doc.team1.id], [(team1win ? 1 : 0), (team1win ? 0 : 1), 0, team1points, 0, team2points, 0, doc.tossups, 0]);

    emit([doc.team2.name, doc.team2.id], [(team1win ? 0 : 1), (team1win ? 1 : 0), 0, team2points, 0, team1points, 0, doc.tossups, 0]);
  }
}