App.TeamsRoute = Ember.Route.extend
  model: -> App.Store.loadSchools()

App.TeamsController = Ember.ArrayController.extend
  sortProperties: ['name']
