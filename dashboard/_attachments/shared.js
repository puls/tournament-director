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
        document.location.href = document.location.href.replace(/\/[^\/]+$/, '/setup.html');
      }
    });
  };
  updateTournament();
  
  schools = {};
  loadSchools = function (callback) {
    app.view('load_schools', {
      success: function (response) {
        schools = {};
        $.each(response.rows, function (index, row) {
          row.value.teams = row.value.teams || {};
          $.each(row.value.teams, function (index, team) {
            team.players = team.players || {};
          });
          schools[row.value._id] = row.value;
        });
        callback();
      }
    });
  };
  
  var tasksRunning = 0;
  startTask = function (name) {
/*    console.log('starting ' + name);*/
    $('#spinner').fadeIn(500);
    tasksRunning++;
  }
  
  stopTask = function (name) {
/*    console.log('stopping ' + name);*/
    tasksRunning--;
    if (tasksRunning < 1) {
      $('#spinner').fadeOut(500);
    }
  }
  
/*  $('h2:not(:first) + div').hide();
  $('h2').click(function (event) {
    var next = $(this).next('div');
    if (next.is(':hidden')) {
    $('h2 + div').slideUp();
    next.slideDown();
    }
  });
  $('h2:first').click();
*/
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