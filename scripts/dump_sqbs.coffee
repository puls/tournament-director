request = require 'request'
fs = require 'fs'

database = require './database'
slug = database.match(/\/([^/]+)$/)[1]
outputDir = process.argv.pop()

request.get "#{database}/tournament", (error, response, body) ->
  tournament = JSON.parse body

  request.get "#{database}/_design/app/_view/by_type?include_docs=true&startkey=[\"tournament\", \"game\"]&endkey=[\"tournament\", \"game\",1]", (error, response, body) ->
    buffer = ""
    teams = []
    players = []
    gameStrings = []

    result = JSON.parse body
    rows = result.rows
    rows.sort (a, b) -> a.doc.round - b.doc.round
    index = 0
    addPlayers = (team) ->
      if teams.indexOf(team.name) == -1
        teams.push team.name
        teamPlayers = team.players.map (p) -> p.name
        players.push teamPlayers
      teamIndex = teams.indexOf(team.name)
      teamPlayers = players[teamIndex]
      return [teamIndex, teamPlayers]
    for row in rows
      index += 1
      doc = row.doc
      if doc.tossups == 0
        if doc.team1.points < doc.team2.points
          [doc.team1, doc.team2] = [doc.team2, doc.team1]
        doc.team1.points = 0
        doc.team2.points = 0
      [team1Index, team1Players] = addPlayers doc.team1
      [team2Index, team2Players] = addPlayers doc.team2
      bonuses = (prev, player) -> prev + player.tens + player.fifteens
      tossupPoints = (prev, player) -> prev + 10 * player.tens + 15 * player.fifteens - 5 * player.negFives
      team1Bonuses = doc.team1.players?.reduce(bonuses, 0) ? 0
      team2Bonuses = doc.team2.players?.reduce(bonuses, 0) ? 0
      team1BonusPoints = doc.team1.points - (doc.team1.players?.reduce(tossupPoints, 0) ? 0)
      team2BonusPoints = doc.team2.points - (doc.team2.players?.reduce(tossupPoints, 0) ? 0)

      gameString = ""
      gameString += "#{index}\r\n#{team1Index}\r\n#{team2Index}\r\n"
      gameString += "#{doc.team1.points}\r\n#{doc.team2.points}\r\n#{doc.tossups}\r\n#{doc.round}\r\n"
      gameString += "#{team1Bonuses}\r\n#{team1BonusPoints}\r\n"
      gameString += "#{team2Bonuses}\r\n#{team2BonusPoints}\r\n"
      gameString += "0\r\n" # not overtime
      gameString += "0\r\n" # team 1 tossups without bonuses
      gameString += "0\r\n" # team 2 tossups without bonuses
      gameString += "#{doc.tossups == 0 ? 1 : 0}\r\n" # forfeit?
      gameString += "0\r\n" # team 1 lightning points
      gameString += "0\r\n" # team 2 lightning points
      for playerIndex in [0...8]
        if playerIndex < doc.team1.players?.length
          player = doc.team1.players[playerIndex]
          gameString += "#{team1Players.indexOf player.name}\r\n"
          gameString += "#{player.tossups / doc.tossups}\r\n"
          gameString += "#{player.fifteens}\r\n"
          gameString += "#{player.tens}\r\n"
          gameString += "#{player.negFives}\r\n"
          gameString += "0\r\n" # fourth question type, not used
          gameString += "#{15 * player.fifteens + 10 * player.tens - 5 * player.negFives}\r\n"
        else
          gameString += "-1\r\n0\r\n0\r\n0\r\n0\r\n0\r\n0\r\n" # line not used, all fields blank

        if playerIndex < doc.team2.players?.length
          player = doc.team2.players[playerIndex]
          gameString += "#{team2Players.indexOf player.name}\r\n"
          gameString += "#{player.tossups / doc.tossups}\r\n"
          gameString += "#{player.fifteens}\r\n"
          gameString += "#{player.tens}\r\n"
          gameString += "#{player.negFives}\r\n"
          gameString += "0\r\n" # fourth question type, not used
          gameString += "#{15 * player.fifteens + 10 * player.tens - 5 * player.negFives}\r\n"
        else
          gameString += "-1\r\n0\r\n0\r\n0\r\n0\r\n0\r\n0\r\n" # line not used, all fields blank
      gameStrings.push gameString
    buffer += "#{teams.length}\r\n"
    index = 0
    for team in teams
      teamPlayers = players[index]
      index++
      buffer += "#{teamPlayers.length + 1}\r\n"
      buffer += "#{team}\r\n"
      for player in teamPlayers
        buffer += "#{player}\r\n"
    buffer += "#{gameStrings.length}\r\n"
    for gameString in gameStrings
      buffer += gameString
    buffer += "1\r\n" # Bonus conversion tracking on
    buffer += "1\r\n" # Bonus conversion tracking automatic
    buffer += "3\r\n" # Track power and neg stats on
    buffer += "0\r\n" # Track lightning rounds off
    buffer += "1\r\n" # Track tossups heard on
    buffer += "1\r\n" # Sort Players by Pts/TUH on
    buffer += "254\r\n" # All warnings on
    buffer += "1\r\n" # Round report enabled
    buffer += "1\r\n" # Team standings report enabled
    buffer += "1\r\n" # Individual standings report enabled
    buffer += "1\r\n" # Scoreboard report enabled
    buffer += "1\r\n" # Team detail report enabled
    buffer += "1\r\n" # Individual detail report enabled
    buffer += "1\r\n" # Stat key enabled
    buffer += "0\r\n" # Custom stylesheet disabled
    buffer += "0\r\n" # Use Divisions disabled
    buffer += "1\r\n" # Sort method 1 (record, then ppg)
    buffer += "#{tournament.name}\r\n" # Tournament name
    buffer += "\r\n" # FTP host
    buffer += "\r\n" # FTP user
    buffer += "\r\n" # FTP path
    buffer += "\r\n" # FTP base filename
    buffer += "0\r\n" # Always use '/' in paths false, British-style reports false
    buffer += "_rounds.html\r\n" #
    buffer += "_standings.html\r\n" #
    buffer += "_individuals.html\r\n" #
    buffer += "_games.html\r\n" #
    buffer += "_teamdetail.html\r\n" #
    buffer += "_playerdetail.html\r\n" #
    buffer += "_statkey.html\r\n" #
    buffer += "\r\n" # Custom stylesheet filename
    buffer += "0\r\n" # Division count
    buffer += "#{teams.length}\r\n"
    for team in teams
      buffer += "-1\r\n" # No divisions in use
    buffer += "15\r\n" # First question type
    buffer += "10\r\n" # Second question type
    buffer += "-5\r\n" # Third question type
    buffer += "0\r\n" # Fourth quesiton type
    buffer += "0\r\n" # Packet name count
    buffer += "#{teams.length}\r\n"
    for team in teams
      buffer += "0\r\n" # Not an exhibition team
    fs.writeFileSync outputDir + '/' + slug, buffer

  header = """
  <HTML>
  <HEAD>
  <TITLE>#{tournament.name} PAGETITLE </TITLE>

  </HEAD>
  <BODY>
  <table border=0 width=100%>
  <tr>
  <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1" />  <td><A HREF=sqbs2_standings.html>Standings</A></td>
    <td><A HREF=#{slug}_individuals.html>Individuals</A></td>
    <td><A HREF=#{slug}_games.html>Scoreboard</A></td>
    <td><A HREF=#{slug}_teamdetail.html>Team Detail</A></td>
    <td><A HREF=#{slug}_playerdetail.html>Individual Detail</A></td>
    <td><A HREF=#{slug}_rounds.html>Round Report</A></td>
    <td><A HREF=#{slug}_statkey.html>Stat Key</A></td>
  </tr>
  </table>
  <H1>#{tournament.name} PAGETITLE </H1><P>
  """

  request.get "#{database}/_design/app/_view/standings?group_level=1", (error, response, body) ->
    result = JSON.parse body
    rows = result.rows.sort (a, b) ->
      if a.value[2] < b.value[2]
        return 1
      if a.value[2] > b.value[2]
        return -1
      if a.value[8] < b.value[8]
        return 1
      if a.value[8] > b.value[8]
        return -1
      return 0
    buffer = header.replace(/PAGETITLE/, 'Team Standings')
    buffer += """<table border=1 width=100%>
      <td ALIGN=LEFT><B>Rank</B></td>
      <td ALIGN=LEFT><B>Team</B></td>
      <td ALIGN=RIGHT><B>W</B></td>
      <td ALIGN=RIGHT><B>L</B></td>
      <td ALIGN=RIGHT><B>T</B></td>
      <td ALIGN=RIGHT><B>Pct</B></td>
      <td ALIGN=RIGHT><B>PPG</B></td>
      <td ALIGN=RIGHT><B>PAPG</B></td>
      <td ALIGN=RIGHT><B>Mrg</B></td>
      <td ALIGN=RIGHT><B>TUH</B></td>
      <td ALIGN=RIGHT><B>P/TU</B></td>
      <td ALIGN=RIGHT><B>BHrd</B></td>
      <td ALIGN=RIGHT><B>BPts</B></td>
      <td ALIGN=RIGHT><B>P/B</B></td>
    </tr>"""
    rank = 0
    for row in rows
      buffer += "<tr>"
      buffer += "<td ALIGN=LEFT>#{rank += 1}</td>"
      buffer += "<td ALIGN=LEFT>#{row.key}</td>"
      buffer += "<td ALIGN=RIGHT>#{row.value[0]}</td>"
      buffer += "<td ALIGN=RIGHT>#{row.value[1]}</td>"
      buffer += "<td ALIGN=RIGHT>0</td>"
      buffer += "<td ALIGN=RIGHT>#{row.value[2].toFixed 2}</td>"
      buffer += "<td ALIGN=RIGHT>#{row.value[4].toFixed 2}</td>"
      buffer += "<td ALIGN=RIGHT>#{row.value[6].toFixed 2}</td>"
      buffer += "<td ALIGN=RIGHT>#{(row.value[4] - row.value[6]).toFixed 2}</td>"
      buffer += "<td ALIGN=RIGHT>#{row.value[7]}</td>"
      buffer += "<td ALIGN=RIGHT>#{(row.value[8] / 20).toFixed 2}</td>"
      buffer += "<td ALIGN=RIGHT>#{row.value[9]}</td>"
      buffer += "<td ALIGN=RIGHT>#{row.value[10]}</td>"
      buffer += "<td ALIGN=RIGHT>#{row.value[11].toFixed 2}</td>"
      buffer += "</tr>"
    buffer += "</table></BODY></HTML>"
    fs.writeFileSync outputDir + '/' + slug + "_standings.html", buffer
