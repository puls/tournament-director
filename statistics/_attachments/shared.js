$.CouchApp(function (app) {
  updateTournament = function () {
    app.db.openDoc('tournament', {
      success: function (doc) {
        tournament = doc;
        $('#tournament_name').text(tournament.name);
      },
      error: function (status, error, reason) {
        app.db.saveDoc({'_id': 'tournament'});
        document.location.href = document.location.href.replace(/\/[^\/]+\/[^\/]+$/, '/dashboard/setup.html');
      }
    });
  };
  updateTournament();
});

