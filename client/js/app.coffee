Ember.LOG_BINDINGS = true

window.App = Ember.Application.create()

App.Router.map () ->
  @resource 'rounds'
  @resource 'settings'
  @resource 'teams', () ->
    @resource 'school', path: ':school_id'

App.ApplicationRoute = Ember.Route.extend
  model: () -> App.Tournament.find(1)

App.ApplicationController = Ember.ObjectController.extend()

App.IndexRoute = Ember.Route.extend
  redirect: () -> @transitionTo 'rounds'

App.TeamsRoute = Ember.Route.extend
  model: () -> App.School.find();

App.TeamsController = Ember.ArrayController.extend
  sortProperties: ['name']

App.RoundsRoute = Ember.Route.extend
  model: () -> App.Game.find();

App.Adapter = DS.RESTAdapter.extend
  namespace: 'api'

App.Store = DS.Store.extend
  revision: 12
  adapter: 'DS.FixtureAdapter'

App.Tournament = DS.Model.extend
  name: DS.attr 'string'
  schools: DS.hasMany 'App.School'
  games: DS.hasMany 'App.Game'

App.Tournament.FIXTURES = [
  { id: 1, name: 'Test Tournament', games: [102], schools: [501] }
]

App.Game = DS.Model.extend
  tournament: DS.belongsTo 'App.Tournament'
  round: DS.attr 'number'
  scoreEntered: DS.attr 'boolean'
  playersEntered: DS.attr 'boolean'
  tossups: DS.attr 'number'
  team1: DS.belongsTo 'App.TeamGame'#, embedded: true
  team2: DS.belongsTo 'App.TeamGame'#, embedded: true

App.Game.FIXTURES = [
  { id: 102, round: 1, scoreEntered: false, playersEntered: false, tossups: 24, team1: 201, team2: 202 }
]

App.TeamGame = DS.Model.extend
  game: DS.belongsTo 'App.Game'
  team: DS.belongsTo 'App.Team'
  name: DS.attr 'string'
  points: DS.attr 'number'
  playerGames: DS.hasMany 'App.PlayerGame'#, embedded: true

App.TeamGame.FIXTURES = [
  { id: 201, team: 3, points: 450, playerGames: [301,302,303] }
  { id: 202, team: 7, points: 5, playerGames: [304,305,306] }
]

App.PlayerGame = DS.Model.extend
  player: DS.belongsTo 'App.Player'
  name: DS.attr 'string'
  tossups: DS.attr 'number'
  fifteens: DS.attr 'number'
  tens: DS.attr 'number'
  negFives: DS.attr 'number'
  teamGame: DS.belongsTo 'App.TeamGame'

App.PlayerGame.FIXTURES = [
  { id: 301, player: 4, tossups: 24, fifteens: 3, tens: 2, negFives: 1 }
  { id: 302, player: 5, tossups: 24, fifteens: 1, tens: 2, negFives: 0 }
  { id: 303, player: 6, tossups: 24, fifteens: 0, tens: 0, negFives: 1 }
  { id: 304, player: 8, tossups: 24, fifteens: 0, tens: 0, negFives: 0 }
  { id: 305, player: 9, tossups: 24, fifteens: 0, tens: 1, negFives: 0 }
  { id: 306, player: 10, tossups: 24, fifteens: 0, tens: 0, negFives: 1 }
]


App.School = DS.Model.extend
  tournament: DS.belongsTo 'App.Tournament'
  name: DS.attr 'string'
  city: DS.attr 'string'
  small: DS.attr 'boolean'
  teams: DS.hasMany 'App.Team'#, embedded: true

App.School.FIXTURES = [
  { id: 501, name: 'Central High', city: 'Somewhere, USA', small: false, teams: [3, 7] }
]

App.Team = DS.Model.extend
  name: DS.attr 'string'
  players: DS.hasMany 'App.Player'#, embedded: true
  school: DS.belongsTo 'App.School'
  teamGames: DS.hasMany 'App.TeamGame'

App.Team.FIXTURES = [
  { id: 3, name: 'Central High A', players: [4,5,6] }
  { id: 7, name: 'Central High B', players: [8,9,10] }
]

App.Player = DS.Model.extend
  name: DS.attr 'string'
  year: DS.attr 'number'
  team: DS.belongsTo 'App.Team'
  playerGames: DS.hasMany 'App.PlayerGame'

App.Player.FIXTURES = [
  {id: 4, name: 'Player Four', year: 10}
  {id: 5, name: 'Player Five', year: 11}
  {id: 6, name: 'Player Six', year: 12}
  {id: 8, name: 'Player Eight', year: 10}
  {id: 9, name: 'Player Nine', year: 11}
  {id: 10, name: 'Player Ten', year: 9}
]