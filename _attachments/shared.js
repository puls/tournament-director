$.CouchApp(function (app) {
    updateTournament = function () {
        app.db.openDoc('tournament', {
            success: function (doc) {
                tournament = doc;
                $('#tournament_name').text(tournament.name);
            },
            error: function (status, error, reason) {
              app.db.saveDoc({'_id': 'tournament'});
              document.location.href = document.location.href.replace(/\/[^\/]+$/, '/setup.html');
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

function getRandomNumber(range) {
	return Math.floor(Math.random() * range);
}

function getRandomChar() {
	var chars = "0123456789abcdef";
	return chars.substr( getRandomNumber(16), 1 );
}

function randomID(size) {
	var str = "";
	for(var i = 0; i < size; i++)
	{
		str += getRandomChar();
	}
	return str;
}