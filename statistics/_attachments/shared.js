$.CouchApp(function (app) {
  updateTournament = function () {
    app.db.openDoc('tournament', {
      success: function (doc) {
        tournament = doc;
        $('#tournament_name').text(tournament.name);
    		if (tournament.flag_title) {
    			$('.flag_title').text(tournament.flag_title);
    		}
      },
      error: function (status, error, reason) {
        app.db.saveDoc({'_id': 'tournament'});
        document.location.href = document.location.href.replace(/\/[^\/]+\/[^\/]+$/, '/dashboard/setup.html');
      }
    });
  };
  updateTournament();
  
  loadSmallSchools = function (callback) {
    var smallSchools = {};
    app.view('small_schools', {
      success: function (response) {
        $.each(response.rows, function (index, row) {
          smallSchools[row.value] = true;
        });
        callback(smallSchools);
      }
    });
  }
});

