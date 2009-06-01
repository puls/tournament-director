function (doc) {
  function to_id(name) {
    result = name.toLowerCase().replace(/[^a-z0-9]+/g,'_');
    return result;
  }
  
  if (doc.type) {
    if (doc.type === 'game' && doc.indivs_complete) {
      emit(['scores', doc.round, to_id(doc.team1.name), to_id(doc.team2.name), doc.team1.points, doc.team2.points, doc.tossups], null);

      for (var key in doc.team1.players) {
        var player = doc.team1.players[key];
        if (player.name && player.name != '') {
          emit(['indstats', doc.round, to_id(doc.team1.name), to_id(doc.team2.name), player.name, doc.tossups, player.tossups, player.fifteens, player.tens, player.negs], null);
        }
      }
      for (var key in doc.team2.players) {
        var player = doc.team2.players[key];
        if (player.name && player.name != '') {
          emit(['indstats', doc.round, to_id(doc.team2.name), to_id(doc.team1.name), player.name, doc.tossups, player.tossups, player.fifteens, player.tens, player.negs], null);
        }
      }
    }
    if (doc.type === 'school') {
      for (var key in doc.teams) {
        var team = doc.teams[key];
        emit(['teams', to_id(team.name), team.name, doc.name, doc.city, doc.small], null);
      }
    }
  }
}