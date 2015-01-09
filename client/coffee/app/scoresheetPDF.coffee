GenerateScoresheetPDF = (match) ->
  doc = new jsPDF('portrait', 'pt', 'letter')

  # In document measurement units, specified above as pts
  pageTop = 36
  pageLeft = 36
  pageWidth = 540
  pageHeight = 702

  thickLineWidth = 1.0
  thinLineWidth = 0.25

  textMarginX = 3
  textMarginY = 4

  headerWidth = 420
  headerHeight = 46

  sectionMargin = 4
  totalBoxHeight = 34

  firstColumnWidth = 108
  teamNameRowHeight = 20
  columnHeaderRowHeight = 90

  # Configurable parameters, as mutiplier factors
  regulationQuestionCount = Math.max(24, match.questions.length)
  overtimeQuestionCount = Math.max(4, match.overtimeQuestions.length)
  playersPerSide = Math.max(match.team1.players.length, match.team2.players.length, 6)
  includeMarginAfterColumnHeader = true

  bonusColumnSize = 1.5

  # There are all the question rows plus two total boxes plus five summary boxes plus four margins plus the two header rows, so work backwards to regular row height
  normalRowHeight = (pageHeight - headerHeight - (if includeMarginAfterColumnHeader then 5 else 4) * sectionMargin - 2 * totalBoxHeight - columnHeaderRowHeight - teamNameRowHeight) / (regulationQuestionCount + overtimeQuestionCount + 5)

  # There are all of the player columns plus three bonus columns per team plus one question number column, so work backwards to the regular column width
  normalColumnWidth = (pageWidth - firstColumnWidth) / (2 * playersPerSide + 6 * bonusColumnSize + 1)

  horizontalLine = (x, y, length, thickness = thinLineWidth) ->
    doc.setLineWidth(thickness)
    doc.line(x, y, x + length, y)

  verticalLine = (x, y, length, thickness = thinLineWidth) ->
    doc.setLineWidth(thickness)
    doc.line(x, y, x, y + length)

  # Header section
  doc.setLineWidth(thickLineWidth)
  doc.setFontSize(10)
  doc.rect(pageLeft, pageTop, headerWidth, headerHeight)

  labelWidth = 10 * doc.getStringUnitWidth(" Scorekeeper ") + 4
  spaceWidth = (headerWidth - 2 * labelWidth) / 2
  verticalLine(pageLeft + labelWidth, pageTop, headerHeight)
  verticalLine(pageLeft + labelWidth + spaceWidth, pageTop, headerHeight)
  verticalLine(pageLeft + 2 * labelWidth + spaceWidth, pageTop, headerHeight)
  horizontalLine(pageLeft, pageTop + headerHeight / 3, headerWidth)
  horizontalLine(pageLeft, pageTop + 2 * headerHeight / 3, headerWidth)

  doc.text("Event", pageLeft + textMarginX, pageTop + headerHeight / 3 - textMarginY)
  doc.text("Room", pageLeft + textMarginX, pageTop + 2 * headerHeight / 3 - textMarginY)
  doc.text("Moderator", pageLeft + textMarginX, pageTop + headerHeight - textMarginY)
  doc.text("Round", pageLeft + headerWidth / 2 + textMarginX, pageTop + headerHeight / 3 - textMarginY)
  doc.text("Packet", pageLeft + headerWidth / 2 + textMarginX, pageTop + 2 * headerHeight / 3 - textMarginY)
  doc.text("Scorekeeper", pageLeft + headerWidth / 2 + textMarginX, pageTop + headerHeight - textMarginY)

  # Main section: Header
  mainSectionHeaderY = pageTop + headerHeight + sectionMargin
  mainSectionHeaderHeight = teamNameRowHeight + columnHeaderRowHeight

  regulationSectionY = mainSectionHeaderY + mainSectionHeaderHeight
  regulationSectionY += sectionMargin if includeMarginAfterColumnHeader
  regulationSectionHeight = regulationQuestionCount * normalRowHeight

  centerColumnStartX = pageLeft + firstColumnWidth + playersPerSide * normalColumnWidth + 3 * bonusColumnSize * normalColumnWidth
  centerColumnEndX = centerColumnStartX + normalColumnWidth

  drawVerticalLines = (startY, length) ->
    verticalLine(pageLeft + firstColumnWidth, startY, length, thickLineWidth)
    verticalLine(centerColumnStartX, startY, length, thickLineWidth)
    verticalLine(centerColumnEndX, startY, length, thickLineWidth)

    for number in [1..playersPerSide]
      thickness = if number is playersPerSide then thickLineWidth else thinLineWidth
      verticalLine(pageLeft + firstColumnWidth + number * normalColumnWidth, startY, length, thickness)
      verticalLine(centerColumnEndX + number * normalColumnWidth, startY, length, thickness)

    for number in [1, 2]
      verticalLine(pageLeft + firstColumnWidth + (playersPerSide + number * bonusColumnSize) * normalColumnWidth, startY, length)
      verticalLine(centerColumnEndX + (playersPerSide + number * bonusColumnSize) * normalColumnWidth, startY, length)

  doc.setLineWidth(thickLineWidth)
  doc.rect(pageLeft, mainSectionHeaderY, pageWidth, mainSectionHeaderHeight)

  verticalLine(pageLeft + firstColumnWidth, mainSectionHeaderY, teamNameRowHeight, thickLineWidth)
  verticalLine(centerColumnStartX, mainSectionHeaderY, teamNameRowHeight, thickLineWidth)
  verticalLine(centerColumnEndX, mainSectionHeaderY, teamNameRowHeight, thickLineWidth)

  drawVerticalLines(mainSectionHeaderY + teamNameRowHeight, columnHeaderRowHeight)

  horizontalLine(pageLeft, mainSectionHeaderY + teamNameRowHeight, centerColumnStartX - pageLeft, thickLineWidth)
  horizontalLine(centerColumnEndX, mainSectionHeaderY + teamNameRowHeight, pageLeft + pageWidth - centerColumnEndX, thickLineWidth)
  horizontalLine(pageLeft, regulationSectionY, pageWidth, thickLineWidth)

  fontSize = 10

  doc.setFontSize(fontSize)
  doc.text("Team Name", pageLeft + textMarginX, mainSectionHeaderY + teamNameRowHeight - (teamNameRowHeight - fontSize + textMarginY) / 2)

  playerNamesY = mainSectionHeaderY + mainSectionHeaderHeight - fontSize - (columnHeaderRowHeight - fontSize) / 2
  doc.setFontSize(fontSize)
  doc.text("Player Names", pageLeft + textMarginX, playerNamesY)
  doc.setFontSize(fontSize * 0.7)
  doc.text("Provide full names in the first\nround; thereafter, at least first\nnames and last initials.", pageLeft + textMarginX, playerNamesY + fontSize)

  doc.setFontSize(fontSize)
  columnHeaderTextY = mainSectionHeaderY + mainSectionHeaderHeight - textMarginX
  doc.text("Tossup Number", centerColumnEndX - textMarginY / 2 - (normalColumnWidth - fontSize) / 2, columnHeaderTextY, 90)

  doc.text("Cumulative Score", centerColumnStartX - textMarginY / 2 - (bonusColumnSize * normalColumnWidth - fontSize) / 2, columnHeaderTextY, 90)
  doc.text("Cumulative Score", pageLeft + pageWidth - textMarginY / 2 - (bonusColumnSize * normalColumnWidth - fontSize) / 2, columnHeaderTextY, 90)

  doc.text("Tossup + Bonus", centerColumnStartX - (bonusColumnSize * normalColumnWidth) - textMarginY / 2 - (bonusColumnSize * normalColumnWidth - fontSize) / 2, columnHeaderTextY, 90)
  doc.text("Tossup + Bonus", pageLeft + pageWidth - (bonusColumnSize * normalColumnWidth) - textMarginY / 2 - (bonusColumnSize * normalColumnWidth - fontSize) / 2, columnHeaderTextY, 90)

  doc.text("Bonus Points", centerColumnStartX - (2 * bonusColumnSize * normalColumnWidth) - textMarginY / 2 - (bonusColumnSize * normalColumnWidth - fontSize) / 2, columnHeaderTextY, 90)
  doc.text("Bonus Points", pageLeft + pageWidth - (2 * bonusColumnSize * normalColumnWidth) - textMarginY / 2 - (bonusColumnSize * normalColumnWidth - fontSize) / 2, columnHeaderTextY, 90)

  # Regulation section
  doc.setLineWidth(thickLineWidth)
  doc.rect(pageLeft, regulationSectionY, pageWidth, regulationSectionHeight)

  runningScoresY = regulationSectionY + (regulationSectionHeight - fontSize) / 2
  doc.setFontSize(fontSize)
  doc.text("Running Scores", pageLeft + textMarginX, runningScoresY)
  doc.setFontSize(fontSize * 0.7)
  doc.text("Indicate 15, 10, or –5 points\nunder the name of the\nappropriate player for each\ntossup.", pageLeft + textMarginX, runningScoresY + fontSize)

  for number in [1..regulationQuestionCount]
    numberFontSize = 9
    doc.setFontSize(numberFontSize)
    numberWidth = doc.getStringUnitWidth(number + "") * numberFontSize
    questionY = regulationSectionY + number * normalRowHeight
    if Math.ceil(number / 3) % 2 == 0
      doc.setFillColor(230, 230, 230)
      doc.rect(pageLeft + firstColumnWidth, questionY - normalRowHeight, pageWidth - firstColumnWidth, normalRowHeight, 'FD')
    doc.text(number + "", centerColumnStartX + (normalColumnWidth - numberWidth) / 2, questionY - textMarginY)
    horizontalLine(pageLeft + firstColumnWidth, questionY, pageWidth - firstColumnWidth) unless number is regulationQuestionCount

  drawVerticalLines(regulationSectionY, regulationSectionHeight)

  # Overtime section
  overtimeSectionHeight = overtimeQuestionCount * normalRowHeight
  overtimeSectionY = regulationSectionY + regulationSectionHeight + sectionMargin

  tiebreakerScoresY = overtimeSectionY + (overtimeSectionHeight - 2.8 * fontSize) / 2
  doc.setFontSize(fontSize)
  doc.text("Tiebreaker", pageLeft + textMarginX, tiebreakerScoresY)
  doc.setFontSize(fontSize * 0.7)
  doc.text("Begin by reading three tossups\nwithout bonuses. If the score is\nthen still tied, read one tossup at\na time until the score changes.", pageLeft + textMarginX, tiebreakerScoresY + fontSize)

  doc.setLineWidth(thickLineWidth)
  doc.rect(pageLeft, overtimeSectionY, pageWidth, overtimeSectionHeight)
  drawVerticalLines(overtimeSectionY, overtimeSectionHeight)
  for number in [1..overtimeQuestionCount]
    questionY = overtimeSectionY + number * normalRowHeight
    horizontalLine(pageLeft + firstColumnWidth, questionY, pageWidth - firstColumnWidth) unless number is overtimeQuestionCount

  doc.setFillColor(127, 127, 127)
  doc.rect(centerColumnStartX - 3 * bonusColumnSize * normalColumnWidth, overtimeSectionY, bonusColumnSize * normalColumnWidth, overtimeSectionHeight, 'FD')
  doc.rect(centerColumnEndX + playersPerSide * normalColumnWidth, overtimeSectionY, bonusColumnSize * normalColumnWidth, overtimeSectionHeight, 'FD')

  # Summary section
  summarySectionHeight = 5 * normalRowHeight + totalBoxHeight
  summarySectionY = overtimeSectionY + overtimeSectionHeight + sectionMargin

  doc.setLineWidth(thickLineWidth)
  doc.rect(pageLeft, summarySectionY, pageWidth, summarySectionHeight)
  drawVerticalLines(summarySectionY, 5 * normalRowHeight)
  for number in [1..5]
    thickness = if number in [1, 4, 5] then thickLineWidth else thinLineWidth
    horizontalLine(pageLeft, summarySectionY + number * normalRowHeight, pageWidth, thickness)

  doc.setFontSize(fontSize)
  doc.text("Player Tossups Heard", pageLeft + textMarginX, summarySectionY + normalRowHeight - textMarginY)
  doc.text("Number of 15s", pageLeft + textMarginX, summarySectionY + 2 * normalRowHeight - textMarginY)
  doc.text("Number of 10s", pageLeft + textMarginX, summarySectionY + 3 * normalRowHeight - textMarginY)
  doc.text("Number of -5s", pageLeft + textMarginX, summarySectionY + 4 * normalRowHeight - textMarginY)
  doc.text("Player Tossup Points", pageLeft + textMarginX, summarySectionY + 5 * normalRowHeight - textMarginY)

  verticalLine(pageLeft + firstColumnWidth, summarySectionY + 5 * normalRowHeight, totalBoxHeight, thickLineWidth)
  verticalLine(pageLeft + firstColumnWidth + playersPerSide * normalColumnWidth, summarySectionY + 5 * normalRowHeight, totalBoxHeight, thickLineWidth)
  verticalLine(centerColumnEndX + playersPerSide * normalColumnWidth, summarySectionY + 5 * normalRowHeight, totalBoxHeight, thickLineWidth)

  doc.text("Subtotals", pageLeft + textMarginX, summarySectionY + 5 * normalRowHeight + fontSize + (totalBoxHeight - fontSize) / 2)

  doc.setFillColor(127, 127, 127)
  doc.rect(centerColumnStartX, summarySectionY, normalColumnWidth, summarySectionHeight, 'FD')
  doc.rect(centerColumnStartX - 3 * bonusColumnSize * normalColumnWidth, summarySectionY, 3 * bonusColumnSize * normalColumnWidth, 5 * normalRowHeight, 'FD')
  doc.rect(centerColumnEndX + playersPerSide * normalColumnWidth, summarySectionY, 3 * bonusColumnSize * normalColumnWidth, 5 * normalRowHeight, 'FD')

  # Final score section
  finalScoreY = pageTop + pageHeight - totalBoxHeight
  doc.setLineWidth(thickLineWidth)
  doc.rect(pageLeft, finalScoreY, pageWidth, totalBoxHeight)
  doc.rect(centerColumnStartX, finalScoreY, normalColumnWidth, totalBoxHeight, 'FD')
  verticalLine(pageLeft + firstColumnWidth, finalScoreY, totalBoxHeight, thickLineWidth)

  doc.setFontSize(fontSize)
  finalScoreTitleY = finalScoreY + (totalBoxHeight - 1.2 * fontSize) / 2
  doc.text("Final Score", pageLeft + textMarginX, finalScoreTitleY)
  doc.setFontSize(fontSize * 0.7)
  doc.text("Sum the tossup subtotal and the\nbonus subtotal.", pageLeft + textMarginX, finalScoreTitleY + fontSize)

  # Extra annotations
  doc.setFontSize(fontSize * 0.7)
  sumAnnotationY = summarySectionY + 5 * normalRowHeight + fontSize
  doc.text("Sum all players’ tossup points.", pageLeft + firstColumnWidth + textMarginX, sumAnnotationY)
  doc.text("Sum the bonus column.", pageLeft + firstColumnWidth + playersPerSide * normalColumnWidth + textMarginX, sumAnnotationY)

  doc.setLineWidth(thinLineWidth)
  doc.setFillColor(255, 255, 255)
  doc.rect(pageLeft + firstColumnWidth + playersPerSide * normalColumnWidth, summarySectionY, fontSize + textMarginY, 5 * normalRowHeight, 'FD')
  doc.text("Include tiebreakers.", pageLeft + firstColumnWidth + playersPerSide * normalColumnWidth + textMarginY, summarySectionY + textMarginX, -90)

  doc.text("Sum all players’ tossup points.", centerColumnEndX + textMarginX, sumAnnotationY)
  doc.text("Sum the bonus column.", centerColumnEndX + playersPerSide * normalColumnWidth + textMarginX, sumAnnotationY)

  doc.setLineWidth(thinLineWidth)
  doc.setFillColor(255, 255, 255)
  doc.rect(centerColumnEndX + playersPerSide * normalColumnWidth, summarySectionY, fontSize + textMarginY, 5 * normalRowHeight, 'FD')
  doc.text("Include tiebreakers.", centerColumnEndX + playersPerSide * normalColumnWidth + textMarginY, summarySectionY + textMarginX, -90)

  doc.text("Use the space below to clarify substitutions, note any questions skipped or read out of order, etc.", pageLeft + textMarginX, pageTop + pageHeight + fontSize)

  # Fill in match data
  doc.setFontType("bold")
  doc.setFontSize(fontSize)

  doc.text(match.event, pageLeft + labelWidth + textMarginX, pageTop + headerHeight / 3 - textMarginY)
  doc.text(match.room, pageLeft + labelWidth + textMarginX, pageTop + 2 * headerHeight / 3 - textMarginY)
  doc.text(match.moderator, pageLeft + labelWidth + textMarginX, pageTop + headerHeight - textMarginY)
  doc.text(match.round + "", pageLeft + 2 * labelWidth + spaceWidth + textMarginX, pageTop + headerHeight / 3 - textMarginY)
  doc.text(match.packet + "", pageLeft + 2 * labelWidth + spaceWidth + textMarginX, pageTop + 2 * headerHeight / 3 - textMarginY)
  doc.text(match.scorekeeper + "", pageLeft + 2 * labelWidth + spaceWidth + textMarginX, pageTop + headerHeight - textMarginY)

  doc.setFontSize(15)
  doc.text(match.team1.name, pageLeft + firstColumnWidth + textMarginX, mainSectionHeaderY + teamNameRowHeight - textMarginY)
  doc.text(match.team2.name, centerColumnEndX + textMarginX, mainSectionHeaderY + teamNameRowHeight - textMarginY)

  doc.setFontSize(fontSize)

  match.team1.players = match.team1.players.filter (player) -> player.tossups > 0
  match.team2.players = match.team2.players.filter (player) -> player.tossups > 0

  index = 0
  for player in match.team1.players
    doc.setFontSize(Math.min(columnHeaderRowHeight / doc.getStringUnitWidth(player.name + "   "), fontSize))
    doc.text(player.name, pageLeft + firstColumnWidth + ++index * normalColumnWidth - (normalColumnWidth - fontSize) / 2, columnHeaderTextY, 90)
  index = 0
  for player in match.team2.players
    doc.setFontSize(Math.min(columnHeaderRowHeight / doc.getStringUnitWidth(player.name + "   "), fontSize))
    doc.text(player.name, centerColumnEndX + ++index * normalColumnWidth - (normalColumnWidth - fontSize) / 2, columnHeaderTextY, 90)

  runningScores = [0, 0]
  doc.setFontSize(fontSize)
  team1Players = match.team1.players.map (player) -> player.name
  team2Players = match.team2.players.map (player) -> player.name

  lastTeam1Lineup = match.team1.lineups[0]
  lastTeam2Lineup = match.team2.lineups[0]

  rightAlignText = (text, x, y, width) ->
    doc.text(text, x + (width - doc.getStringUnitWidth(text) * fontSize) - textMarginX, y)

  outputQuestionResult = (question, index, isOvertime = false) ->
    for lineup in match.team1.lineups
      if lineup.firstQuestion == index + 1
        lastTeam1Lineup = lineup
    for lineup in match.team2.lineups
      if lineup.firstQuestion == index + 1
        lastTeam2Lineup = lineup

    questionY = (if isOvertime then overtimeSectionY else regulationSectionY) + (index + 1) * normalRowHeight
    questionTextY = questionY - textMarginY

    for playerIndex in [0..team1Players.length - 1]
      if team1Players[playerIndex] not in lastTeam1Lineup.players
        verticalLine(pageLeft + firstColumnWidth + (playerIndex + 0.5) * normalColumnWidth, questionY - normalRowHeight, normalRowHeight, thinLineWidth)
    for playerIndex in [0..team2Players.length - 1]
      if team2Players[playerIndex] not in lastTeam2Lineup.players
        verticalLine(centerColumnEndX + (playerIndex + 0.5) * normalColumnWidth, questionY - normalRowHeight, normalRowHeight, thinLineWidth)

    if question.answer?.team_id == match.team1.id
      questionPoints = question.answer.points + question.bonus_points
      rightAlignText(question.answer.points + "", pageLeft + firstColumnWidth + normalColumnWidth * team1Players.indexOf(question.answer.player), questionTextY, normalColumnWidth)
      runningScores[0] += questionPoints
      rightAlignText(question.bonus_points + "", pageLeft + firstColumnWidth + playersPerSide * normalColumnWidth, questionTextY, normalColumnWidth * bonusColumnSize) unless isOvertime
      rightAlignText(questionPoints + "", pageLeft + firstColumnWidth + (playersPerSide + bonusColumnSize) * normalColumnWidth, questionTextY, normalColumnWidth * bonusColumnSize)
    else if question.answer?.team_id == match.team2.id
      questionPoints = question.answer.points + question.bonus_points
      rightAlignText(question.answer.points + "", centerColumnEndX + normalColumnWidth * team2Players.indexOf(question.answer.player), questionTextY, normalColumnWidth)
      runningScores[1] += questionPoints
      rightAlignText(question.bonus_points + "", centerColumnEndX + playersPerSide * normalColumnWidth, questionTextY, bonusColumnSize * normalColumnWidth) unless isOvertime
      rightAlignText(questionPoints + "", centerColumnEndX + (playersPerSide + bonusColumnSize) * normalColumnWidth, questionTextY, bonusColumnSize * normalColumnWidth)
    else
      doc.setLineWidth(thinLineWidth)
      doc.line(centerColumnStartX, questionY, centerColumnEndX, questionY - normalRowHeight)

    if question.neg?.team_id == match.team1.id
      rightAlignText(question.neg.points + "", pageLeft + firstColumnWidth + normalColumnWidth * team1Players.indexOf(question.neg.player), questionTextY, normalColumnWidth)
      runningScores[0] += question.neg.points
      rightAlignText(question.neg.points + "", pageLeft + firstColumnWidth + (playersPerSide + bonusColumnSize) * normalColumnWidth, questionTextY, bonusColumnSize * normalColumnWidth)
    else if question.neg?.team_id == match.team2.id
      rightAlignText(question.neg.points + "", centerColumnEndX + normalColumnWidth * team2Players.indexOf(question.neg.player), questionTextY, normalColumnWidth)
      runningScores[1] += question.neg.points
      rightAlignText(question.neg.points + "", centerColumnEndX + (playersPerSide + bonusColumnSize) * normalColumnWidth, questionTextY, bonusColumnSize * normalColumnWidth)

    rightAlignText(runningScores[0] + "", pageLeft + firstColumnWidth + (playersPerSide + 2 * bonusColumnSize) * normalColumnWidth, questionTextY, bonusColumnSize * normalColumnWidth)
    rightAlignText(runningScores[1] + "", centerColumnEndX + (playersPerSide + 2 * bonusColumnSize) * normalColumnWidth, questionTextY, bonusColumnSize * normalColumnWidth)

  index = 0
  outputQuestionResult question, index++, false for question in match.questions
  index = 0
  outputQuestionResult question, index++, true for question in (match.overtimeQuestions ? [])

  index = 0
  team1TossupPoints = 0
  for player in match.team1.players
    playerPoints = 15 * player.fifteens + 10 * player.tens - 5 * player.negFives
    team1TossupPoints += playerPoints
    rightAlignText(player.tossups + "", pageLeft + firstColumnWidth + index * normalColumnWidth, summarySectionY + normalRowHeight - textMarginY, normalColumnWidth)
    rightAlignText(player.fifteens + "", pageLeft + firstColumnWidth + index * normalColumnWidth, summarySectionY + 2 * normalRowHeight - textMarginY, normalColumnWidth)
    rightAlignText(player.tens + "", pageLeft + firstColumnWidth + index * normalColumnWidth, summarySectionY + 3 * normalRowHeight - textMarginY, normalColumnWidth)
    rightAlignText(player.negFives + "", pageLeft + firstColumnWidth + index * normalColumnWidth, summarySectionY + 4 * normalRowHeight - textMarginY, normalColumnWidth)
    rightAlignText(playerPoints + "", pageLeft + firstColumnWidth + index * normalColumnWidth, summarySectionY + 5 * normalRowHeight - textMarginY, normalColumnWidth)
    index++
  team1BonusPoints = match.team1.points - team1TossupPoints

  index = 0
  team2TossupPoints = 0
  for player in match.team2.players
    playerPoints = 15 * player.fifteens + 10 * player.tens - 5 * player.negFives
    team2TossupPoints += playerPoints
    rightAlignText(player.tossups + "", centerColumnEndX + index * normalColumnWidth, summarySectionY + normalRowHeight - textMarginY, normalColumnWidth)
    rightAlignText(player.fifteens + "", centerColumnEndX + index * normalColumnWidth, summarySectionY + 2 * normalRowHeight - textMarginY, normalColumnWidth)
    rightAlignText(player.tens + "", centerColumnEndX + index * normalColumnWidth, summarySectionY + 3 * normalRowHeight - textMarginY, normalColumnWidth)
    rightAlignText(player.negFives + "", centerColumnEndX + index * normalColumnWidth, summarySectionY + 4 * normalRowHeight - textMarginY, normalColumnWidth)
    rightAlignText(playerPoints + "", centerColumnEndX + index * normalColumnWidth, summarySectionY + 5 * normalRowHeight - textMarginY, normalColumnWidth)
    index++
  team2BonusPoints = match.team2.points - team2TossupPoints

  doc.setFontSize(20)
  doc.text(team1TossupPoints + "", pageLeft + firstColumnWidth + textMarginX, summarySectionY + summarySectionHeight - textMarginY)
  doc.text(team1BonusPoints + "", pageLeft + firstColumnWidth + playersPerSide * normalColumnWidth + textMarginX, summarySectionY + summarySectionHeight - textMarginY)
  doc.text(team2TossupPoints + "", centerColumnEndX + textMarginX, summarySectionY + summarySectionHeight - textMarginY)
  doc.text(team2BonusPoints + "", centerColumnEndX + playersPerSide * normalColumnWidth + textMarginX, summarySectionY + summarySectionHeight - textMarginY)

  doc.setFontSize(35)
  doc.text(match.team1.points + "", pageLeft + firstColumnWidth + textMarginX, finalScoreY + totalBoxHeight - textMarginY)
  doc.text(match.team2.points + "", centerColumnEndX + textMarginX, finalScoreY + totalBoxHeight - textMarginY)

  doc.output('datauri')
