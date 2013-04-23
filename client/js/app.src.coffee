Ember.LOG_BINDINGS = true

window.App = Ember.Application.create()

Ember.TextSupport.reopen
  attributeBindings: ["style"]

App.Router.reopen
  location: 'history'

App.Router.map ->
  @resource 'rounds', ->
    @resource 'round', path: ':round_id', ->
      @resource 'editGame', path: ':game_id'
  @resource 'settings'
  @resource 'teams', ->
    @resource 'school', path: ':school_id'
  @resource 'standings', ->
    @resource 'teamStandings', path: 'teams'
    @resource 'playerStandings', path: 'players'
    @resource 'scoreboard'

App.ApplicationRoute = Ember.Route.extend
  model: -> App.Store.loadTournament()

App.ApplicationController = Ember.ObjectController.extend()

App.StandingsRoute = Ember.Route.extend()
  # redirect: -> @transitionTo 'teamStandings'

App.TeamStandingsRoute = Ember.Route.extend
  model: -> App.Store.loadTeamStandings()

App.TeamStandingsController = Ember.ArrayController.extend
  sortProperties: ['value.2','value.8']
  sortAscending: false

App.PlayerStandingsRoute = Ember.Route.extend
  model: -> App.Store.loadPlayerStandings()

App.PlayerStandingsController = Ember.ArrayController.extend
  sortProperties: ['value.7','key.1']
  sortAscending: false

App.IndexRoute = Ember.Route.extend()
  # redirect: -> @transitionTo 'rounds'

App.TeamsRoute = Ember.Route.extend
  model: -> App.Store.loadSchools()

App.TeamsController = Ember.ArrayController.extend
  sortProperties: ['name']

App.RoundsRoute = Ember.Route.extend
  model: -> App.Store.loadRounds()
  setupController: (controller, model) -> App.Store.loadSchoolsIfEmpty()

App.RoundsController = Ember.ArrayController.extend
  reloadRounds: ->
    @set 'content', App.Store.loadRounds()
    @controllerFor('round').reloadGames()

App.RoundRoute = Ember.Route.extend
  model: (params) -> App.Round.create id: params.round_id
  setupController: (controller, model) ->
    controller.reloadGames()
    App.LatestRound = model.id

App.RoundController = Ember.ObjectController.extend
  reloadGames: ->
    @set 'games', App.Store.loadGamesForRound @get 'id'

App.EditGameRoute = Ember.Route.extend
  model: (params) ->
    game = App.Game.create _id: "game_#{params.game_id}"
    game.reload()
    game

App.EditGameController = Ember.ObjectController.extend
  hide: ->
    @controllerFor('rounds').reloadRounds()
    @transitionToRoute 'round'
  modalDidHide: -> @hide()
  cancel: -> @hide()
  save: -> alert 'save'
  deleteGame: ->
    game = @get 'content'
    game.deleteRecord
      error: (xhr, status, error) -> alert status
      success: (data, status, xhr) => @hide()


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
    for team in ['team1','team2']
      @set team, App.TeamGame.create @get(team)

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
    representation._id = "game_#{@get 'round'}_#{@get 'team1.id'}_#{@get 'team2.id'}"
    representation

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
App.Round = Ember.Object.extend()
App.Team = Ember.Object.extend()
App.TeamGame = Ember.Object.extend()

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

  loadTeamStandings: ->
    lines = Ember.ArrayProxy.create content: []
    @loadView 'standings',
      group: true
      (data, status) -> lines.set 'content', data.rows.map (row) -> row
    lines

  loadPlayerStandings: ->
    lines = Ember.ArrayProxy.create content: []
    @loadView 'players',
      group: true
      (data, status) -> lines.set 'content', data.rows.map (row) -> row
    lines

  classForType: (type) ->
    type = type[0].toUpperCase() + type.substr 1
    App[type]

  loadObject: (id) ->
    proxy = Ember.ObjectProxy.create content: {}
    Ember.$.ajax "/api/#{id}",
      dataType: 'json'
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
      success: success
      dataType: 'json'

App.ScoreForm = Ember.View.extend
  tagName: 'form'
  templateName: 'scoreForm'
  classNames: ['score-form', 'form-inline']

  init: ->
    @_super()
    @set 'game', App.Game.create()

  didInsertElement: -> @$('input:first').val(App.LatestRound).focus()

  submit: (event) ->
    event.preventDefault()
    game = @get 'game'
    game.saveScore
      error: (xhr, status, error) -> alert status
      success: (data, status, xhr) =>
        @set 'game', App.Game.create()
        controller = @get 'controller'
        controller.reloadRounds()

App.PlayersForm = Ember.View.extend
  tagName: 'form'
  templateName: 'playersForm'
  classNames: 'modal fade in form-custom-field-modal'.w()
  didInsertElement: ->
     @$().modal 'show'
     @$().on 'hide', =>
      @get('controller').modalDidHide()
  willDestroyElement: ->
    @$().modal 'hide'

Ember.Handlebars.registerBoundHelper 'fixedDecimal', (value, options) ->
  new Handlebars.SafeString value.toFixed 2

App.Counters = {}
Ember.Handlebars.registerBoundHelper 'counter', (key, options) ->
  new Handlebars.SafeString App.Counters[key] += 1
Ember.Handlebars.registerBoundHelper 'resetCounter', (key, options) ->
  App.Counters[key] = 0
  ""
