$.CouchApp(function (app) {
    updateTournament = function () {
        app.db.openDoc('tournament', {
            success: function (doc) {
                tournament = doc;
                $('#tournament_name').text(tournament.name);
            }
        });
    };
    updateTournament();
    
    $('h2:not(:first) + div').hide();
    $('h2').click(function (event) {
      var next = $(this).next('div');
      if (next.is(':hidden')) {
        $('h2 + div').slideUp();
        next.slideDown();
      }
    });
    $('h2:first').click();
});
