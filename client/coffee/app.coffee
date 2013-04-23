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

App.ApplicationRoute = Ember.Route.extend
  model: -> App.Store.loadTournament()

App.ApplicationController = Ember.ObjectController.extend()

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
