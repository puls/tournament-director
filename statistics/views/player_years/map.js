function (doc) {
  if (doc.type && doc.type === 'school') {
    for each (var team in doc.teams) {
      for each (var player in team.players) {
        emit([team.name, player.name], player.year);
      }
    }
  }
}