function (doc) {
  if (doc.type && doc.type === 'game' && doc.entry_complete && doc.round != 10) {
    var team1win = (doc.team1.points > doc.team2.points);
    var team1points = (doc.team1.points == 1 ? 0 : doc.team1.points);
    var team2points = (doc.team2.points == 1 ? 0 : doc.team2.points);

    var tossups1 = 0;
    var tossups2 = 0;
    var bonuspoints1 = doc.team1.points;
    var bonuspoints2 = doc.team2.points;
    for each (var player in doc.team1.players) {
      tossups1 += player.fifteens + player.tens;
      bonuspoints1 -= (15 * player.fifteens + 10 * player.tens - 5 * player.negs);
    };
    for each (var player in doc.team2.players) {
      tossups2 += player.fifteens + player.tens;
      bonuspoints2 -= (15 * player.fifteens + 10 * player.tens - 5 * player.negs);
    };
    
    emit([doc.team1.name, doc.team1.id, doc.bracket], [(team1win ? 1 : 0), (team1win ? 0 : 1), 0, team1points, 0, team2points, 0, doc.tossups, 0, tossups1, bonuspoints1, 0]);
    emit([doc.team2.name, doc.team2.id, doc.bracket], [(team1win ? 0 : 1), (team1win ? 1 : 0), 0, team2points, 0, team1points, 0, doc.tossups, 0, tossups2, bonuspoints2, 0]);
  }
}
