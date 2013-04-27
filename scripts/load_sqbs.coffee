fs = require 'fs'
to_id = require './to_id'
request = require 'request'

database = 'http://localhost:5984/qbtd'

theWholeEnchilada = fs.readFileSync process.argv.pop(), encoding: 'utf8'
lines = theWholeEnchilada.split "\n"

teamCount = parseInt lines.shift(), 10
tournamentName = process.argv.pop()
docs = [{
  _id: 'tournament'
  name: tournamentName
  type: 'tournament'
}]
lastSchool = null
while teamCount > 0
  teamCount -= 1
  lineCount = parseInt lines.shift(), 10
  team = name: lines.shift(), players: []
  team.id = to_id(team.name)

  match = team.name.match /(.+?)( [A-Z])?$/
  schoolName = match[1]
  unless lastSchool?.name == schoolName
    lastSchool =
      name: schoolName
      tournament: 'tournament'
      teams: []
      type: 'school'
      _id: "school_#{to_id schoolName}"
    docs.push lastSchool
  lastSchool.teams.push team

  lineCount -= 1
  while lineCount > 0
    match = lines.shift().match /(.+?)( \((\d+)\))?$/
    team.players.push
      name: match[1]
      year: parseInt match[3], 10
    lineCount -= 1

request.del database, (error, response, body) ->
  request.put database, (error, response, body) ->
    request
      url: "#{database}/_bulk_docs"
      method: 'POST'
      json: {docs: docs}
      (error, response, body) -> console.log "Done"
