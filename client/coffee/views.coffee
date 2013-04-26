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
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: (data, status, xhr) =>
        @set 'game', App.Game.create()
        controller = @get 'controller'
        controller.reloadRounds()

App.PlayersForm = Ember.View.extend
  tagName: 'form'
  templateName: 'playersForm'
  contentBinding: 'controller.content'
  classNames: 'modal fade in form-custom-field-modal'.w()

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
              @set key, data.rows.map (row) -> row.key[1]
          )(key)

  autocompletePlayers: (team, text) ->
    key = @keyForTeam team
    @get(key).filter (name) -> team.get('players').every (player) -> player.name isnt name

App.NameField = Ember.TextField.extend
  didInsertElement: ->
    @get('parentView').loadPlayerNames()
    @$().typeahead
      source: (text, callback) =>
        @get('parentView').autocompletePlayers @get('team'), text, callback


App.NumberField = Ember.TextField.extend
  type: 'number'
  attributeBindings: ['min', 'max', 'step']
  _elementValueDidChange: ->
    number = parseInt @$().val(), 10
    number = if isNaN(number) then 0 else number
    @set 'value', number
    @$().val number

Ember.Handlebars.registerBoundHelper 'fixedDecimal', (value, options) ->
  new Handlebars.SafeString value.toFixed 2

App.Counters = {}
Ember.Handlebars.registerBoundHelper 'counter', (key, options) ->
  new Handlebars.SafeString App.Counters[key] += 1
Ember.Handlebars.registerBoundHelper 'resetCounter', (key, options) ->
  App.Counters[key] = 0
  ""
