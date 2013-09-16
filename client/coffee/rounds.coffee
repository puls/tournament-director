App.RoundsRoute = Ember.Route.extend
  model: -> App.Store.loadRounds()
  setupController: (controller, model) ->
    @_super controller, model
    App.Store.loadSchoolsIfEmpty()
    unless controller.get('pendingGames')?
      controller.set 'pendingGames', App.PendingGamesList.create()

App.RoundsController = Ember.ArrayController.extend
  reloadRounds: ->
    @set 'content', App.Store.loadRounds()
    @get('pendingGames').reload()
    @controllerFor('round').reloadGames()

App.RoundRoute = Ember.Route.extend
  model: (params) ->
    if params.round_id is 'pending'
      list = App.PendingGamesList.create()
      list.reload()
      @controllerFor('rounds').set 'pendingGames', list
      list
    else
      App.Round.create id: params.round_id
  setupController: (controller, model) ->
    @_super controller, model
    controller.reloadGames()
    App.LatestRound = model.id unless model.id is 'pending'

App.RoundController = Ember.ObjectController.extend
  reloadGames: ->
    if @get('id') is 'pending'
      @set 'games', @get 'content.games'
    else
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
  save: ->
    game = @get 'content'
    game.savePlayers
      validationError: (message) -> alert message
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: (data, status, xhr) => @hide()

  deleteGame: ->
    game = @get 'content'
    game.deleteRecord
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: (data, status, xhr) => @hide()
