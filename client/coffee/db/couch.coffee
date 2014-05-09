console.log 'using CouchDB as database'

App.Model = Ember.Object.extend
  init: ->
    @_super()
    @setID()

  setID: ->
    type = @get 'type'
    if @get('_id')?
      @set 'id', @get('_id').replace "#{type}_", ''

  url: -> "/api/#{@get '_id'}"

  reload: ->
    Ember.$.ajax
      url: @url()
      type: 'GET'
      dataType: 'json'
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: (data, status) =>
        @setProperties data
        @setID()

  deleteRecord: (options) ->
    Ember.$.ajax
      url: @url() + '?rev=' + @get '_rev'
      type: 'DELETE'
      success: options.success
      error: options.error

App.ModelStore = Ember.Object.extend
  loadObject: (id) ->
    proxy = Ember.ObjectProxy.create content: {}
    Ember.$.ajax "/api/#{id}",
      dataType: 'json'
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: (data, status) =>
        proxy.set 'content', @classForType(data.type).create data
    proxy

  loadObjectsOfType: (type, callback) ->
    objects = Ember.ArrayProxy.create content: []

    @loadView 'by_type',
      include_docs: true
      key: ['tournament', type]
      (data, status) =>
        objects.set 'content', data.rows.map (row) =>
          thisType = row.doc.type
          @classForType(thisType).create row.doc
        callback objects

    objects

  loadView: (view, options, success) ->
    for optionKey in 'startkey endkey key'.w()
      if typeof options[optionKey] == 'object'
        options[optionKey] = JSON.stringify options[optionKey]
    Ember.$.ajax "/api/_design/app/_view/#{view}",
      data: options
      error: (xhr, status, error) -> alert JSON.parse(xhr.responseText).reason
      success: success
      dataType: 'json'
