App.StandingsRoute = Ember.Route.extend
  model: -> Ember.Object.create({filterRounds: false, minRound: 0, maxRound: 0})

App.StandingsController = Ember.ObjectController.extend
  updateFilters: ->
    console.log "Filter on: #{@get 'filterRounds'}; min #{@get 'minRound'} max #{@get 'maxRound'}"

App.StandingsIndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'teamStandings'

App.TeamStandingsRoute = Ember.Route.extend
  model: -> App.Store.rowsFromView 'standings'

App.TeamStandingsController = Ember.ArrayController.extend
  sortProperties: ['value.2','value.8']
  sortAscending: false

App.PlayerStandingsRoute = Ember.Route.extend
  model: -> App.Store.rowsFromView 'players'
  setupController: (controller, model) ->
    controller.set 'allYears', App.Store.rowsFromView 'player_years'

App.PlayerStandingsController = Ember.ArrayController.extend
  sortProperties: ['value.7','key.1']
  sortAscending: false

  addYears: (->
    if @get('allYears.length') == 0 or @get('content.length') == 0
      return
    allYears = @get 'allYears.content'
    yearOptions = []
    @forEach (player) ->
      console.log "Adding year to #{player.key[1]}"
      index = 0
      spliceIndex = -1
      for row in allYears
        if player.key[0] == row.key[0] and player.key[1] == row.key[1]
          player.key[2] = row.value
          allYears.splice index, 1
          break
        index += 1
  ).observes 'allYears.content', 'content'

App.ScoreboardRoute = Ember.Route.extend
  model: -> App.Store.rowsFromView 'scoreboard'

App.ScoreboardController = Ember.ArrayController.extend
  rounds: (->
    groups = {}
    rounds = []
    @forEach (row, index, enumerable) ->
      round = row.key[0]
      if !groups[round]?
        groups[round] = {id: round, games: []}
        rounds.push groups[round]
      groups[round].games.push row.key
    rounds
  ).property 'content.@each'

