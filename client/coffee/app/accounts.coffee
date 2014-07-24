App.LoggedInRoute = Ember.Route.extend
  beforeModel: (transition) ->
    @_super transition
    unless App.Session.loggedIn
      App.Session.set 'afterLoginTransition', transition
      @transitionTo 'login'

App.LoginRoute = Ember.Route.extend
  actions:
    submit: (username, password) -> 
      success = (data, status, xhr) =>
        App.Session.reload()

      Ember.$.ajax
        url: '/_session'
        type: 'POST'
        data: "name=#{encodeURIComponent username}&password=#{encodeURIComponent password}"
        contentType: 'application/x-www-form-urlencoded'
        error: -> alert 'error'
        success: success
