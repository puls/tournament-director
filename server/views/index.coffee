fs = require 'fs'
path = require 'path'
module.exports = views =

  player_years:
    map: (doc) ->
      if doc.type and doc.type is 'school'
        for team_id, team of doc.teams
          for player_id, player of team.players
            emit [ team.name, player.name ], player.year

  scoreboard:
    map: (doc) -> 
      if doc.type and doc.type is 'game' and doc.entry_complete
        emit [ doc.round, doc.team1.name, doc.team1.points, doc.team2.name, doc.team2.points ], null
  
  small_schools:
    map: (doc) ->
      if doc.type and doc.type is 'school' and doc.small
        for key of doc.teams
          emit key, doc.teams[key].name
    

for filename in fs.readdirSync __dirname
  continue if filename == path.basename __filename
  key = path.basename filename, path.extname filename
  views[key] = require "./#{filename}"