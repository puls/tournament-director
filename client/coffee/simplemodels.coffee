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

  saveScore: (options) ->
    Ember.$.ajax
      url: '/api/'
      type: 'POST'
      data: JSON.stringify @scoreRepresentation()
      contentType: 'application/json'
      error: options.error
      success: options.success

  savePlayers: (options) ->
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

  rowsFromView: (view) ->
    lines = Ember.ArrayProxy.create content: []
    @loadView view,
      group: true
      (data, status) -> lines.set 'content', data.rows
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
