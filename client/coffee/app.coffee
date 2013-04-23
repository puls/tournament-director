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

App.StandingsIndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'teamStandings'

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

App.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'rounds'

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

