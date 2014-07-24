App.TeamsRoute = App.LoggedInRoute.extend
  model: -> App.Store.loadSchools()

App.TeamsController = Ember.ArrayController.extend
  sortProperties: ['name']
  actions:
    edit: (school) -> school.set 'editing', true

    addSchool: ->
      school = App.School.create name: ''
      school.set 'editing', true
      @addObject school
    addTeam: (school) -> school.addTeam()
    addPlayer: (team) -> team.players.pushObject {}

    cancel: (school) ->
      school.set 'editing', false
      @set 'model', App.Store.loadSchools()

    save: (school) ->
      school.save
        error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
        success: (data, status, xhr) -> school.set 'editing', false

    deleteSchool: (school) ->
      school.deleteRecord
        error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
        success: (data, status, xhr) => @removeObject school
