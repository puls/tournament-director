App.RoundsRoute = App.LoggedInRoute.extend
  model: -> App.Store.loadRounds()
  setupController: (controller, model) ->
    @_super controller, model
    App.Store.loadSchoolsIfEmpty()
    unless controller.get('pendingGames')?
      controller.set 'pendingGames', App.PendingGamesList.create()

App.RoundsController = Ember.ArrayController.extend
  needs: ['round']
  reloadRounds: ->
    @set 'content', App.Store.loadRounds()
    @get('pendingGames').reload()
    @get('controllers.round').reloadGames()

App.RoundRoute = App.LoggedInRoute.extend
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

  actions:
    generatePDF: (game) ->
      GenerateScoresheetPDF(game)
    sort: (column) ->
      @set 'games', @get('content.games').sortBy(column)

App.EditGameRoute = App.LoggedInRoute.extend
  model: (params) ->
    game = App.Game.create _id: "game_#{params.game_id}"
    game.reload (game) -> game.ensureEmptyPlayerGames()
    game

App.EditGameController = Ember.ObjectController.extend
  needs: ['rounds']
  hide: ->
    game = @get 'content'
    game.clearEmptyPlayerGames()
    @get('controllers.rounds').reloadRounds()
    @transitionToRoute 'round'

    # We've removed the modal's element by the time the hidden event triggers, so do its side effects manually.
    $(document.body).removeClass 'modal-open'
  modalDidHide: -> @hide()

  actions:
    cancel: -> @hide()
    save: ->
      game = @get 'content'
      game.clearEmptyPlayerGames()
      game.savePlayers
        validationError: (message) -> alert message
        error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
        success: (data, status, xhr) => @hide()

    deleteGame: ->
      game = @get 'content'
      game.clearEmptyPlayerGames()
      game.deleteRecord
        error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
        success: (data, status, xhr) => @hide()
