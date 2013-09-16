App.StandingsRoute = Ember.Route.extend
  model: -> Ember.Object.create({filterRounds: false, minRound: 0, maxRound: 0})

App.StandingsController = Ember.ObjectController.extend
  updateFilters: ->
    console.log "Filter on: #{@get 'filterRounds'}; min #{@get 'minRound'} max #{@get 'maxRound'}"

App.StandingsIndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'teamStandings'

App.TeamStandingsRoute = Ember.Route.extend
  model: -> App.Store.rowsFromView 'standings'
  setupController: (controller, model) ->
    @_super controller, model
    controller.set 'smallSchools', App.Store.rowsFromView 'small_schools'

App.TeamStandingsController = Ember.ArrayController.extend
  sortProperties: ['value.2','value.8']
  sortAscending: false
  sort: (key) ->
    App.Counters['standings'] = 0
    @set 'sortAscending', key is 'key.0'
    @set 'sortProperties', [key]

  addSmall: (->
    if @get('smallSchools.length') == 0
      console.log 'No small schools, bailing'
      return

    if @get('content.length') == 0
      console.log 'No teams, bailing'
      return

    smallSchools = @get 'smallSchools.content'
    schoolsMap = {}
    for row in smallSchools
      schoolsMap[row.key] = true
    @forEach (team) ->
      team.key[2] = schoolsMap[team.key[1]]?
  ).observes 'smallSchools.content', 'content'

App.PlayerStandingsRoute = Ember.Route.extend
  model: -> App.Store.rowsFromView 'players'
  setupController: (controller, model) ->
    @_super controller, model
    controller.set 'allYears', App.Store.rowsFromView 'player_years'

App.PlayerStandingsController = Ember.ArrayController.extend
  sortProperties: ['value.7','key.1']
  sortAscending: false

  sort: (key) ->
    App.Counters['standings'] = 0
    @set 'sortAscending', key is 'key.1'
    @set 'sortProperties', [key]

  addYears: (->
    if @get('allYears.length') == 0
      console.log 'No player years, bailing'
      return

    if @get('content.length') == 0
      console.log 'No players, bailing'
      return

    allYears = @get 'allYears.content'
    yearOptions = []
    @forEach (player) ->
      index = 0
      spliceIndex = -1
      for row in allYears
        if player.key[0] == row.key[0] and player.key[1] == row.key[1]
          player.key[2] = row.value
          allYears.splice index, 1
          break
        index += 1
  )#.observes 'allYears.content', 'content'

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

App.TeamPerformanceRoute = Ember.Route.extend
  model: (params) ->
    teamID = parseInt params.team_id, 10
    App.Store.rowsFromView 'by_team',
      startkey: JSON.stringify [teamID]
      endkey: JSON.stringify [teamID, {}]
      group: false

App.TeamPerformanceController = Ember.ArrayController.extend()
