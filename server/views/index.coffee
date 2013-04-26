fs = require 'fs'
path = require 'path'
module.exports = views =

  player_years:
    map: (doc) ->
      if doc.type and doc.type is 'school'
        for team in doc.teams
          for player in team.players
            emit [ team.name, player.name ], player.year

  player_names:
    map: (doc) ->
      emit_names = (team) ->
        for player in team.players
          emit [team.name, player.name]
      if doc.type
        if doc.type is 'school'
          emit_names team for team in doc.teams
        if doc.type is 'game'
          emit_names team for team in [doc.team1, doc.team2]
    reduce: '_count'

  pending_games:
    map: (doc) ->
      if doc.type and doc.type is 'game' and !doc.playersEntered
        emit doc._id

  scoreboard:
    map: (doc) ->
      if doc.type and doc.type is 'game' and doc.scoreEntered
        emit [ doc.round, doc.team1.name, doc.team1.points, doc.team2.name, doc.team2.points ], null
    reduce: '_count'

  small_schools:
    map: (doc) ->
      if doc.type and doc.type is 'school' and doc.small
        for team in doc.teams
          emit team.id, team.name


for filename in fs.readdirSync __dirname
  continue if filename == path.basename __filename
  key = path.basename filename, path.extname filename
  views[key] = require "./#{filename}"