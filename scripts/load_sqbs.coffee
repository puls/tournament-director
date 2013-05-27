fs = require 'fs'
to_id = require './to_id'
request = require 'request'

database = require './database'

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
  teamName = lines.shift()
  match = teamName.match /((.+?)( [A-Z])?)( \(SS\))?( team_id:(\d+))?$/

  team = name: match[1], players: []
  team._id = to_id(team.name)
  team.id = parseInt match[6], 10
  team.small = match[4]?.length > 0

  schoolName = match[2]
  unless lastSchool?.name == schoolName
    lastSchool =
      name: schoolName
      tournament: 'tournament'
      teams: []
      type: 'school'
      small: team.small
      _id: "school_#{to_id schoolName}"
    docs.push lastSchool
  lastSchool.teams.push team

  lineCount -= 1
  while lineCount > 0
    match = lines.shift().match /(.+?)( \((\d+)\))?( team_member_id:(\d+))?$/
    team.players.push
      name: match[1]
      year: parseInt match[3], 10
      id: parseInt match[5], 10
    lineCount -= 1

request.del database, (error, response, body) ->
  request.put database, (error, response, body) ->
    request
      url: "#{database}/_bulk_docs"
      method: 'POST'
      json: {docs: docs}
      (error, response, body) -> console.log "Done"
