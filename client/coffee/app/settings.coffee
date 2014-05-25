App.SettingsRoute = Ember.Route.extend
  model: ->
    App.Store.get 'tournament'

App.SettingsController = Ember.ObjectController.extend
  actions:
    save: ->
      @get('model').get('content').save
        error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
        success: (data, status, xhr) -> alert 'it worked'
