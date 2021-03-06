App.Utility ?= {}
App.Utility.to_id = (name) -> name.toLowerCase().replace /[^a-z0-9]+/g,'_'

App.Game = App.Model.extend
  init: ->
    @_super()
    @wrapTeams()

  setProperties: (properties) ->
    @_super(properties)
    @wrapTeams()

  wrapTeams: ->
    for team in ['team1', 'team2']
      wrappedTeam = App.TeamGame.create @get(team)
      @set team, wrappedTeam
      wrappedTeam.wrapPlayers()
    @clearOvertime()

  teams: (-> [@get('team1'), @get('team2')]).property 'team1', 'team2'
  hasOvertime: (-> @get('overtimeTossups') > 0).property 'overtimeTossups'
  hasFullQuestionData: (-> @get('questions.length') > 0).property 'questions'

  clearOvertime: (->
    if @get('overtimeTossups') == 0
      for team in ['team1', 'team2']
        players = @get "#{team}.players"
        if players?
          for player in players
            player.set 'overtime', {}
            player.setDefaultZeroes()
  ).observes 'overtimeTossups'

  scoreRepresentation: () ->
    representation = @getProperties 'round', 'tossups', 'room', 'serial', 'overtimeTossups'
    for team in ['team1', 'team2']
      representation[team] = @get(team).getProperties 'id', 'points'
      representation[team].points = parseInt representation[team].points, 10
      representation[team].name = App.Store.teamLookup[representation[team].id].get 'name'
      representation[team].players = []
    for key in ['round', 'tossups', 'overtimeTossups']
      representation[key] = parseInt representation[key], 10
    representation.overtimeTossups = 0 unless representation.overtimeTossups
    representation.scoreEntered = true
    representation.playersEntered = representation.tossups == 0
    representation.type = 'game'
    representation.tournament = 'tournament'
    representation._id = "game_#{@get 'round'}_#{@get 'team1.id'}_#{@get 'team2.id'}"
    representation

  ensureEmptyPlayerGames: ->
    console.log("Adding empty player games", this)
    for team in @get 'teams'
      if team.get('players').every((player) -> player.get('name')?.length > 0)
        team.get('players').pushObject App.PlayerGame.create
          tossups: @get 'tossups'
          overtime:
            tossups: @get 'overtimeTossups'

  clearEmptyPlayerGames: ->
    for team in @get 'teams'
      team.set 'players', team.get('players').filter((player) -> player.get('name')?.length > 0)

  validateScore: ->
    return 'Round cannot be blank' unless @get 'round'
    return 'Left team cannot be blank' unless @get 'team1.id'
    return 'Right team cannot be blank' unless @get 'team2.id'
    return 'Left score cannot be blank' unless @get('team1.points')?.toString().length
    return 'Right score cannot be blank' unless @get('team2.points')?.toString().length
    return 'Tossups cannot be blank' unless @get 'tossups'
    return 'Serial cannot be blank' unless @get 'serial'
    return 'Room cannot be blank' unless @get 'room'

    return 'Round must be greater than 0'  if @get('round') <= 0
    return 'Round must be less than 30'  if @get('round') > 30

    leftScore = parseInt @get('team1.points'), 10
    rightScore = parseInt @get('team2.points'), 10
    tossups = parseInt @get('tossups'), 10

    if (leftScore is 1 or rightScore is 1) and tossups is 0
      return null

    overtimeTossups = parseInt @get('overtimeTossups'), 10
    return 'Tossups must be more than 10' if tossups < 10
    return 'Regulation tossups must be less than 27' if tossups - overtimeTossups > 26

    return 'Left team points must be a multiple of 5' if leftScore % 5 isnt 0
    return 'Right team points must be a multiple of 5' if rightScore % 5 isnt 0

  saveScore: (options) ->
    message = @validateScore()
    return options.validationError(message) if message?
    representation = @scoreRepresentation()
    Ember.$.ajax
      url: '/api/'
      type: 'POST'
      data: JSON.stringify representation
      contentType: 'application/json'
      error: options.error
      success: options.success

  validatePlayers: ->
    gameTossups = @get 'tossups'
    overtimeTossups = @get 'overtimeTossups'
    for teamKey in ['team1', 'team2']
      team = @get teamKey
      players = team.get 'playersWithNames'
      seatsFilled = Math.min 4, players.length
      expectedTossups = seatsFilled * gameTossups
      return "#{team.name} players heard more than #{expectedTossups} tossups" if team.get('playerTossups') > expectedTossups
      return "#{team.name} players heard less than #{expectedTossups} tossups" if team.get('playerTossups') < expectedTossups

      bonusPoints = team.get('bonusPoints')
      return "#{team.name} had less than zero bonus points" if bonusPoints < 0
      return "#{team.name} had #{bonusPoints} bonus points, which totally isn't a thing anymore. Go back to the year 2014, you heathen." if bonusPoints % 10 != 0

      pointsPerBonus = bonusPoints / team.get('bonusesHeard')
      return "#{team.name} averaged #{pointsPerBonus} points per bonus" if pointsPerBonus > 30

      for player in players
        playerTossups = player.get 'tossups'
        playerOvertimeTossups = player.get 'overtime.tossups'
        if playerTossups > gameTossups
          return "#{team.name}: #{player.name} heard more tossups (#{playerTossups}) than the team did (#{gameTossups})"
        if player.get('answered') > playerTossups
          return "#{team.name}: #{player.name} answered more tossups (#{player.get 'answered'}) than he/she heard (#{playerTossups})"
        if playerOvertimeTossups > overtimeTossups
          return "#{team.name}: #{player.name} heard more overtime tossups (#{playerOvertimeTossups}) than the team did (#{overtimeTossups})"


  savePlayers: (options) ->
    message = @validateScore()
    return options.validationError(message) if message?

    message = @validatePlayers()
    return options.validationError(message) if message?

    representation = @scoreRepresentation()
    for team in ['team1', 'team2']
      representation[team].players = @get(team).get 'playersWithNames'
    representation.playersEntered = true
    representation._rev = @get '_rev'
    Ember.$.ajax
      url: @url()
      type: 'PUT'
      data: JSON.stringify representation
      contentType: 'application/json'
      error: options.error
      success: options.success

App.Tournament = App.Model.extend()
App.School = App.Model.extend
  init: (contents) ->
    @_super()
    @set 'type', 'school'
    @set 'tournament', 'tournament'
    unless @get('teams')?.length
      @set 'teams', []
      @addTeam()

  addTeam: ->
    teamName = @get('name')
    teamCount = @get('teams').length
    if teamCount > 0
      teamLetter = String.fromCharCode('A'.charCodeAt(0) + teamCount)
      teamName = teamName + ' ' + teamLetter
    newTeam =
      name: teamName
      players: [{}, {}, {}, {}]
    @get('teams').pushObject newTeam

  ensureEmptyPlayerLines: ->
    for team in @get 'teams'
      if team.players.every((player) -> player.name?.length > 0)
        team.players.pushObject {}

  save: (options) ->
    unless @get('_id')?
      @set '_id', App.Utility.to_id "School #{@get('name')}"
    unless @get('id')?
      @set 'id', App.Utility.to_id "School #{@get('name')}"
    for team in @get 'teams'
      team._id = App.Utility.to_id team.name unless team._id?
      team.id = App.Utility.to_id team.name unless team.id?
      Ember.set team, 'players', team.players.filter (player) -> player?.name?.length > 0

    representation = @getProperties 'city', 'location', 'id', 'name', 'small', 'teams', 'tournament', 'tournament_id', 'type', '_rev'
    unless representation.location?
      representation.location = ""
    Ember.$.ajax
      url: @url()
      type: 'PUT'
      data: JSON.stringify representation
      contentType: 'application/json'
      error: options.error
      success: options.success

App.Round = Ember.Object.extend
  pending: false

App.PendingGamesList = App.Round.extend
  init: ->
    @_super()
    @reload()
  id: 'pending'
  pending: true
  gameCount: (-> @get 'games.length').property 'games'
  reload: ->
    @set 'games', []
    App.Store.loadView 'pending_games',
      include_docs: true
      (data, status) =>
        @set 'games', data.rows.map (row) -> App.Game.create row.doc

App.Team = Ember.Object.extend
  nameWithLocation: (->
    location = @get('location')
    if location?
      [city, state] = location.split(', ')
    else
      city = null
      state = null
    name = @get 'name'
    if state? then "#{name} (#{state})" else name
  ).property('name', 'location')
  loadPerformance: ->
    id = @get 'id'
    @set 'performanceData', App.Store.rowsFromView 'by_team',
      startkey: [id]
      endkey: [id, {}]
      group: false
  games: (->
    data = @get('performanceData').get 'content'
    games = []
    lastGame = null
    @set 'name', data[0].key[1] if data.length > 0
    for row in data
      if lastGame?.id isnt row.id
        lastGame = id: row.id
        games.push lastGame
      if row.key[3] is 'team'
        lastGame.round = row.key[2]
        lastGame.opponent = row.value[0]
        lastGame.points = row.value[1]
        lastGame.opponentPoints = row.value[2]
        lastGame.tossups = row.value[3]
        lastGame.win = row.value[1] > row.value[2]
        lastGame.loss = row.value[1] < row.value[2]
        lastGame.forfeit = lastGame.tossups == 0
      else
        player = row.value[1..]
        player.unshift row.key[3]
        player.push 15 * player[2] + 10 * player[3] - 5 * player[4]
        lastGame.players ?= []
        lastGame.players.push player
    games
  ).property 'performanceData.content'

App.TeamGame = Ember.Object.extend
  init: ->
    @_super()
    @wrapPlayers()

  wrapPlayers: ->
    playerObjects = @get 'players'
    if playerObjects?
      @set 'players', playerObjects.map (player) -> App.PlayerGame.create player
    else
      @set 'players', []

  playersWithNames: (-> @get('players').filter (player) -> player.get('name')?.length > 0).property 'players.@each.name'

  playerTossups: (-> @sum 'tossups').property 'players.@each.tossups'
  tens: (-> @sum 'tens').property 'players.@each.tens'
  fifteens: (-> @sum 'fifteens').property 'players.@each.fifteens'
  negFives: (-> @sum 'negFives').property 'players.@each.negFives'
  tossupPoints: (-> @sum 'points').property 'players.@each.points'
  bonusesHeard: (-> @sum('tens') + @sum('fifteens') - @sum('overtime.tens') - @sum('overtime.fifteens')).property 'tens', 'fifteens', 'overtime.tens', 'overtime.fifteens'
  bonusPoints: (-> @get('points') - @get('tossupPoints')).property 'tossupPoints', 'points'
  sum: (key) ->
    @get('playersWithNames').reduce ((acc, item, index, enumerable) -> acc + item.get key), 0

App.PlayerGame = Ember.Object.extend
  init: ->
    @_super()
    @setDefaultZeroes()

  setDefaultZeroes: ->
    for property in ['tens', 'fifteens', 'negFives', 'tossups']
      if !@get property
        @set property, 0
      if !@get 'overtime'
        @set 'overtime', {}
      if !@get "overtime.#{property}"
        @set "overtime.#{property}", 0

  points: (-> 10 * @get('tens') + 15 * @get('fifteens') - 5 * @get('negFives')).property 'tens', 'fifteens', 'negFives'
  answered: (-> @get('tens') + @get('fifteens') + @get('negFives')).property 'tens', 'fifteens', 'negFives'

App.Store = App.ModelStore.extend
  loadTournament: -> @loadObject 'tournament'

  loadRounds: ->
    rounds = Ember.ArrayProxy.create content: []

    @loadView 'scoreboard',
      group_level: 1
      (data, status) ->
        rounds.set 'content', data.rows.map (row) ->
          App.Round.create id: row.key[0]

    rounds

  loadGamesForRound: (round_id) ->
    round_id = parseInt round_id, 10
    games = Ember.ArrayProxy.create content: []

    @loadView 'scoreboard',
      startkey: [round_id]
      endkey: [round_id, {}]
      include_docs: true
      reduce: false
      (data, status) =>
        games.set 'content', data.rows.map (row) =>
          thisType = row.doc.type
          @classForType(thisType).create row.doc

    games

  rowsFromView: (view, options) ->
    lines = Ember.ArrayProxy.create content: []
    options = $.extend {group: true}, options unless options?.group
    @loadView view, options, (data, status) ->
      console.log "Fetched view #{view}"
      lines.set 'content', data.rows
    lines

  classForType: (type) ->
    type = type[0].toUpperCase() + type.substr 1
    App[type]

  allSchools: Ember.ArrayProxy.create content: []
  allTeams: Ember.ArrayProxy.create content: []
  teamLookup: {}
  loadSchools: ->
    @allSchools = @loadObjectsOfType 'school', (objects) =>
      @allTeams.set 'content', []
      objects.forEach (school) =>
        location = school.get 'location'
        for team in school.get 'teams'
          console.log "setting location #{location} on #{team.name} from #{school.get('name')}"
          team = App.Team.create team
          team.set 'location', location
          @allTeams.pushObject team
          @teamLookup[team.id] = team
      @allTeams.set 'content', @allTeams.sortBy 'name'

  loadSchoolsIfEmpty: -> @loadSchools() if @allSchools.get('length') is 0

App.Store = new App.Store()

App.Session = Ember.Object.extend
  init: ->
    @_super()
    @reload()

  loggedIn: false

  displayName: (-> @get('profile.fullName') ? @get('profile.name') ? '??').property 'profile.name', 'profile.fullName'

  reload: (cb) ->
    wasLoggedIn = @get 'loggedIn'
    Ember.$.ajax
      url: '/_session'
      dataType: 'json'
      success: (data, response, xhr) =>
        loggedIn = data.userCtx.name?
        @set 'profile', data.userCtx
        @set 'loggedIn', loggedIn
        if loggedIn and !wasLoggedIn
          transition = @get 'afterLoginTransition'
          @set 'afterLoginTransition', null
          if transition?
            transition.retry()
        cb?(loggedIn)

  clear: -> @set 'loggedIn', false

App.Session = new App.Session()
