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
    @resource 'teamPerformance', path: 'teams/:team_id'
    @resource 'playerStandings', path: 'players'
    @resource 'scoreboard'

App.ApplicationRoute = Ember.Route.extend
  model: -> App.Store.loadTournament()

App.ApplicationController = Ember.ObjectController.extend()

App.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'rounds'
