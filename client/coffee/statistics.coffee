App.StandingsIndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'teamStandings'

App.TeamStandingsRoute = Ember.Route.extend
  model: -> App.Store.rowsFromView 'standings'

App.TeamStandingsController = Ember.ArrayController.extend
  sortProperties: ['value.2','value.8']
  sortAscending: false

App.PlayerStandingsRoute = Ember.Route.extend
  model: -> App.Store.rowsFromView 'players'

App.PlayerStandingsController = Ember.ArrayController.extend
  sortProperties: ['value.7','key.1']
  sortAscending: false

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

