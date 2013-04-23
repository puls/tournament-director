App.Serializer = DS.CouchDBSerializer.extend
  typeAttribute: 'type'
  stringForType: (type) -> type.toString().split('.').pop().toLowerCase()

App.Adapter = DS.CouchDBAdapter.extend
  typeAttribute: 'type',
  typeViewName: 'by_type',
  serializer: App.Serializer

App.Tournament = DS.Model.extend
  name: DS.attr 'string'
  schools: DS.hasMany 'App.School'
  games: DS.hasMany 'App.Game'

App.Game = DS.Model.extend
  tournament: DS.belongsTo 'App.Tournament'
  round: DS.attr 'number'
  scoreEntered: DS.attr 'boolean'
  playersEntered: DS.attr 'boolean'
  tossups: DS.attr 'number'
  team1: DS.belongsTo 'App.TeamGame'
  team2: DS.belongsTo 'App.TeamGame'

App.Adapter.map App.Game,
  team1: {embedded: 'always'}
  team2: {embedded: 'always'}

App.TeamGame = DS.Model.extend
  team: DS.belongsTo 'App.Team'
  name: DS.attr 'string'
  points: DS.attr 'number'
  playerGames: DS.hasMany 'App.PlayerGame'

App.Adapter.map App.TeamGame,
  playerGames: {embedded: 'always'}

App.PlayerGame = DS.Model.extend
  player: DS.belongsTo 'App.Player'
  name: DS.attr 'string'
  tossups: DS.attr 'number'
  fifteens: DS.attr 'number'
  tens: DS.attr 'number'
  negFives: DS.attr 'number'

App.School = DS.Model.extend
  tournament: DS.belongsTo 'App.Tournament'
  name: DS.attr 'string'
  city: DS.attr 'string'
  small: DS.attr 'boolean'
  teams: DS.hasMany 'App.Team'

App.Adapter.map App.School,
  teams: {embedded: 'always'}

App.Team = DS.Model.extend
  name: DS.attr 'string'
  players: DS.hasMany 'App.Player'
  school: DS.belongsTo 'App.School'
  teamGames: DS.hasMany 'App.TeamGame'

App.Adapter.map App.Team,
  players: {embedded: 'always'}

App.Player = DS.Model.extend
  name: DS.attr 'string'
  year: DS.attr 'number'
  team: DS.belongsTo 'App.Team'
  playerGames: DS.hasMany 'App.PlayerGame'

App.Store = DS.Store.extend
  revision: 12
  adapter: App.Adapter.create
    db: 'api'
    designDoc: 'app'

