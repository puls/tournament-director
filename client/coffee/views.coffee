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
      validationError: (message) -> alert message
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: (data, status, xhr) =>
        @set 'game', App.Game.create()
        controller = @get 'controller'
        controller.reloadRounds()

App.PlayersForm = Ember.View.extend
  tagName: 'form'
  templateName: 'playersForm'
  contentBinding: 'controller.content'
  classNames: 'modal fade in form-custom-field-modal non-fixed-modal form-inline'.w()

  didInsertElement: ->
    @$().modal 'show'
    @$('input:first').focus()
    @$().on 'hide', =>
      @get('controller').modalDidHide()

  willDestroyElement: ->
    @$().modal 'hide'

  eventManager: Ember.Object.create
    focusOut: (event, view) ->
      game = view.get('controller').get 'content'
      game.ensureEmptyPlayerGames()

  keyForTeam: (team) -> "playerNames_#{team.get('id')}"

  loadPlayerNames: ->
    for team in @get 'content.teams'
      if team.get('id')?
        key = @keyForTeam team
        if !@get(key)?
          @set key, []
          ((key) => App.Store.loadView 'player_names',
            startkey: JSON.stringify [team.get 'name']
            endkey: JSON.stringify [team.get('name'), 'zzzzz']
            group: true
            (data, status) =>
              players = {}
              for row in data.rows
                players[row.key[1]] = row.value
              @set key, players
          )(key)

  autocompletePlayers: (team, text) ->
    key = @keyForTeam team
    players = team.get 'players'
    names = []
    for own name, value of @get(key)
      if (players.every (player) -> player.name isnt name)
        names.push name
    names

  sortAutocomplete: (team, items) ->
    key = @keyForTeam team
    nameScores = @get key
    items.sort (a, b) -> nameScores[a] - nameScores[b]

App.NameField = Ember.TextField.extend
  didInsertElement: ->
    @get('parentView').loadPlayerNames()
    @$().typeahead
      sorter: (items) =>
        @get('parentView').sortAutocomplete @get('team'), items
      source: (text) =>
        @get('parentView').autocompletePlayers @get('team'), text


App.NumberField = Ember.TextField.extend
  type: 'number'
  attributeBindings: ['min', 'max', 'step']
  _elementValueDidChange: ->
    originalValue = @$().val()
    number = parseInt originalValue, 10
    number = if isNaN(number) then 0 else number
    @set 'value', number
    if originalValue != number.toString()
      @$().val number

  focusIn: (event, view) ->
    @$().select()

App.FilterForm = Ember.View.extend
  tagName: 'form'
  templateName: 'filterForm'
  classNames: ['pull-right','filterForm']
  eventManager:
    change: (event, view) ->
      view.get('controller').updateFilters()

Ember.Handlebars.registerBoundHelper 'fixedDecimal', (value, options) ->
  new Handlebars.SafeString value.toFixed 2

App.Counters = {}
Ember.Handlebars.registerBoundHelper 'counter', (key, options) ->
  new Handlebars.SafeString App.Counters[key] += 1
Ember.Handlebars.registerBoundHelper 'resetCounter', (key, options) ->
  App.Counters[key] = 0
  ""
