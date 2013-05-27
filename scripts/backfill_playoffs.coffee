request = require 'request'

database = require './database'
docs = []
request.get "#{database}/tournament", (error, response, body) ->
  tournament = JSON.parse body
  request.get "#{database}/_design/app/_view/by_type?key=[\"tournament\",\"game\"]&include_docs=true", (error, response, body) ->
    for row in JSON.parse(body).rows
      doc = row.doc
      doc.playoffs = (doc.round >= tournament.firstPlayoffRound)
      docs.push doc
    request
      url: "#{database}/_bulk_docs"
      method: 'POST'
      json: {docs: docs}
