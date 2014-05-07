module.exports = lists =
  readView: "module.exports = " + ((file) ->
    start
      'headers':
        'Content-Type': 'text/csv'
        'Content-Disposition': 'attachment; filename="' + file + '"'
    teamMemberLookup = {}
    while (row = getRow())
      switch row.key.shift()
        when 'scores' then send row.key.join(',') + "\n" if file is 'scores'
        when 'teams' then send row.key.join(',') + "\n" if file is 'teams'
        when '_players' then teamMemberLookup[row.key.join ''] = row.value
        when 'indstats'
          if file is 'indstats'
            playerName = row.key[4]
            row.key[4] = teamMemberLookup[row.key[2] + playerName] ? playerName
            send row.key.join(',') + "\n"
    "").toString()

  indstats: (head, req) -> require('lists/readView') 'indstats'
  teams: (head, req) -> require('lists/readView') 'teams'
  scores: (head, req) -> require('lists/readView') 'scores'
