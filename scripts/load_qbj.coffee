fs = require 'fs'
to_id = require './to_id'
request = require 'request'

database = require './database'

theWholeEnchilada = fs.readFileSync process.argv.pop(), encoding: 'utf8'
rootObject = JSON.parse theWholeEnchilada

if rootObject.version != '1.2'
  console.log "Unsupported QBJ version #{rootObject.version}"
  return

docs = []
for object in rootObject.objects
  if object.type == 'Registration'
    docs.push
      _id: object.id
      type: 'school'
      tournament: 'tournament'
      name: object.name
      location: object.location
      small: false
      org_id: object.org_id
      teams: object.teams

  else if object.type == 'Tournament'
    docs.push
      _id: 'tournament'
      type: 'tournament'
      name: object.name


request.del database, (error, response, body) ->
  request.put database, (error, response, body) ->
    request
      url: "#{database}/_bulk_docs"
      method: 'POST'
      json: {docs: docs}
      (error, response, body) -> console.log "Done"
