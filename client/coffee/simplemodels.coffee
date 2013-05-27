App.Model = Ember.Object.extend
  init: ->
    @_super()
    @setID()

  setID: ->
    type = @get 'type'
    if @get('_id')?
      @set 'id', @get('_id').replace "#{type}_", ''

  url: -> "/api/#{@get '_id'}"

  reload: ->
    Ember.$.ajax
      url: @url()
      type: 'GET'
      dataType: 'json'
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: (data, status) =>
        @setProperties data
        @setID()

  deleteRecord: (options) ->
    Ember.$.ajax
      url: @url() + '?rev=' + @get '_rev'
      type: 'DELETE'
      success: options.success
      error: options.error

App.Game = App.Model.extend
  init: ->
    @_super()
    @wrapTeams()

  setProperties: (properties) ->
    @_super(properties)
    @wrapTeams()

  wrapTeams: ->
    for team in ['team1','team2']
      wrappedTeam = App.TeamGame.create @get(team)
      @set team, wrappedTeam
      wrappedTeam.wrapPlayers()
    @ensureEmptyPlayerGames()

  teams: (-> [@get('team1'), @get('team2')]).property 'team1','team2'

  scoreRepresentation: () ->
    representation = @getProperties 'round','tossups','room','serial'
    for team in ['team1','team2']
      representation[team] = @get(team).getProperties 'id','points'
      representation[team].points = parseInt representation[team].points, 10
      representation[team].name = App.Store.teamLookup[representation[team].id].get 'name'
    for key in ['round','tossups']
      representation[key] = parseInt representation[key], 10
    representation.scoreEntered = true
    representation.playersEntered = false
    representation.type = 'game'
    representation.tournament = 'tournament'
    representation._id = "game_#{@get 'round'}_#{@get 'team1.id'}_#{@get 'team2.id'}"
    representation

  ensureEmptyPlayerGames: ->
    for team in @get 'teams'
      if team.get('players').every((player) -> player.get('name')?.length > 0)
        team.get('players').pushObject App.PlayerGame.create tossups: @get 'tossups'

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

    tossups = parseInt @get('tossups'), 10
    return 'Tossups must be more than 10' if tossups < 10
    return 'Tossups must be less than 30' if tossups > 30

    leftScore = parseInt @get('team1.points'), 10
    return 'Left team points must be a multiple of 5' if leftScore % 5 isnt 0

    rightScore = parseInt @get('team2.points'), 10
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
    for teamKey in ['team1', 'team2']
      team = @get teamKey
      players = team.get 'playersWithNames'
      seatsFilled = Math.min 4, players.length
      expectedTossups = seatsFilled * gameTossups
      return "#{team.name} players heard more than #{expectedTossups} tossups" if team.get('tossups') > expectedTossups
      return "#{team.name} players heard less than #{expectedTossups} tossups" if team.get('tossups') < expectedTossups

      return "#{team.name} had less than zero bonus points" if team.get('bonusPoints') < 0

      pointsPerBonus = team.get('bonusPoints') / team.get('bonusesHeard')
      return "#{team.name} averaged #{pointsPerBonus} points per bonus" if pointsPerBonus > 30

      for player in players
        playerTossups = player.get 'tossups'
        if playerTossups > gameTossups
          return "#{team.name}: #{player.name} heard more tossups (#{playerTossups}) than the team did (#{gameTossups})"
        if player.get('answered') > playerTossups
          return "#{team.name}: #{player.name} answered more tossups (#{player.get 'answered'}) than he/she heard (#{playerTossups})"


  savePlayers: (options) ->
    message = @validateScore()
    return options.validationError(message) if message?

    message = @validatePlayers()
    return options.validationError(message) if message?

    representation = @scoreRepresentation()
    for team in ['team1','team2']
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
App.School = App.Model.extend()
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

App.Team = Ember.Object.extend()
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
  bonusesHeard: (-> @sum('tens') + @sum('fifteens')).property 'tens', 'fifteens'
  bonusPoints: (-> @get('points') - @get('tossupPoints')).property 'tossupPoints', 'points'
  sum: (key) ->
    @get('playersWithNames').reduce ((acc, item, index, enumerable) -> acc + item.get key), 0


App.PlayerGame = Ember.Object.extend
  init: ->
    @_super()
    for property in ['tens', 'fifteens', 'negFives', 'tossups']
      if !@get property
        @set property, 0
  points: (-> 10 * @get('tens') + 15 * @get('fifteens') - 5 * @get('negFives')).property 'tens','fifteens','negFives'
  answered: (-> @get('tens') + @get('fifteens') + @get('negFives')).property 'tens','fifteens','negFives'

App.Store =
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
      startkey: JSON.stringify [round_id]
      endkey: JSON.stringify [round_id, {}]
      include_docs: true
      reduce: false
      (data, status) =>
        games.set 'content', data.rows.map (row) =>
          thisType = row.doc.type
          @classForType(thisType).create row.doc

    games

  rowsFromView: (view, options) ->
    lines = Ember.ArrayProxy.create content: []
    options = $.extend {group: true}, options unless options.group?
    @loadView view, options, (data, status) -> lines.set 'content', data.rows
    lines

  classForType: (type) ->
    type = type[0].toUpperCase() + type.substr 1
    App[type]

  loadObject: (id) ->
    proxy = Ember.ObjectProxy.create content: {}
    Ember.$.ajax "/api/#{id}",
      dataType: 'json'
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: (data, status) =>
        proxy.set 'content', @classForType(data.type).create data
    proxy

  allSchools: Ember.ArrayProxy.create content: []
  allTeams: Ember.ArrayProxy.create content: []
  teamLookup: {}
  loadSchools: ->
    @allSchools = @loadObjectsOfType 'school', (objects) =>
      @allTeams.set 'content', []
      for teamList in objects.mapProperty 'teams'
        for team in teamList
          team = App.Team.create team
          @allTeams.pushObject team
          @teamLookup[team.id] = team

  loadSchoolsIfEmpty: -> @loadSchools() if @allSchools.get('length') is 0

  loadObjectsOfType: (type, callback) ->
    objects = Ember.ArrayProxy.create content: []

    @loadView 'by_type',
      include_docs: true
      key: JSON.stringify ['tournament', type]
      (data, status) =>
        objects.set 'content', data.rows.map (row) =>
          thisType = row.doc.type
          @classForType(thisType).create row.doc
        callback objects

    objects

  loadView: (view, options, success) ->
    Ember.$.ajax "/api/_design/app/_view/#{view}",
      data: options
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: success
      dataType: 'json'
