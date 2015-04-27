App.StandingsRoute = Ember.Route.extend
  model: -> Ember.Object.create({filterRounds: false, minRound: 0, maxRound: 0})

App.StandingsController = Ember.ObjectController.extend
  updateFilters: ->
    console.log "Filter on: #{@get 'filterRounds'}; min #{@get 'minRound'} max #{@get 'maxRound'}"

App.StandingsIndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'teamStandings'

App.TeamStandingsIndexRoute = Ember.Route.extend
  model: -> App.Store.rowsFromView 'standings'
  setupController: (controller, model) ->
    @_super controller, model
    controller.set 'smallSchools', App.Store.rowsFromView 'small_schools'
  actions:
    showTeam: (view) ->
      team = view.get 'team'
      teamKey = team.key[1]
      @transitionTo 'teamPerformance', teamKey

App.TeamStandingsIndexController = Ember.ArrayController.extend
  sortProperties: ['value.2', 'value.8']
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

    console.log 'Adding small schools to teams'

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
  sortProperties: ['value.7', 'key.1']
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

    console.log 'Adding years to players'

    allYears = @get 'allYears.content'
    yearOptions = []
    @forEach (player) ->
      index = 0
      spliceIndex = -1
      player.hasYear = true
      for row in allYears
        if player.key[0] == row.key[0] and player.key[1] == row.key[1]
          player.key[3] = row.value
          allYears.splice index, 1
          break
        index += 1
  ).observes 'allYears.content', 'content'

  actions:
    showPlayer: (view) ->
      player = view.get 'player'
      teamKey = player.key[2]
      @transitionTo 'teamPerformance', teamKey

App.ScoreboardIndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'scoreboardRound', 'all'

App.ScoreboardRoute = Ember.Route.extend
  model: -> App.Store.rowsFromView 'scoreboard', group: false

App.ScoreboardController = Ember.ArrayController.extend
  roundNumbers: (->
    min = @get 'content.firstObject.value.min'
    max = @get 'content.firstObject.value.max'
    ['all'].concat(num for num in [min..max])
  ).property 'content.@each'

App.ScoreboardRoundRoute = Ember.Route.extend
  model: (params) ->
    options = {}
    round = parseInt(params.round_id, 10)
    if round > 0
      options =
        startkey: [round]
        endkey: [round, {}]
    App.Store.rowsFromView 'scoreboard', options

App.ScoreboardRoundController = Ember.ArrayController.extend
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
    App.Team.create id: params.team_id
  setupController: (controller, model) ->
    @_super controller, model
    model.loadPerformance()
