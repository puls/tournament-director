request = require 'request'
csv = require 'csv'
fs = require 'fs'

database = require './database'

outputDir = process.argv.pop()

indstatsFile = csv().to "#{outputDir}/indstats"
scoresFile = csv().to "#{outputDir}/scores"
teamsFile = csv().to "#{outputDir}/teams"

teamMemberLookup = {}

request.get "#{database}/_design/app/_view/livestat", (error, response, body) ->
  for row in JSON.parse(body).rows
    switch row.key.shift()
      when 'scores' then scoresFile.write row.key
      when 'teams' then teamsFile.write row.key
      when '_players' then teamMemberLookup[row.key.join ''] = row.value
      when 'indstats'
        playerName = row.key[4]
        row.key[4] = teamMemberLookup[row.key[2] + playerName] ? playerName
        indstatsFile.write row.key

  indstatsFile.end()
  scoresFile.end()
  teamsFile.end()
