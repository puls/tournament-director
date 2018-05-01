App.ExportRoute = Ember.Route.extend
  model: -> App.Store.loadTournament()

App.ExportController = Ember.ObjectController.extend
  actions: 
    import: ->
      input = $('#importFile')[0]
      blowAwayEverything = $('#blowAwayEverything').is(':checked')
      fileList = input.files
      return unless fileList.length > 0
      file = fileList[0]
      reader = new FileReader()
      reader.onload = (event) =>
        rootObject = JSON.parse(event.target.result)
        newDocs = []
        for object in rootObject.objects
          if object.type == 'Registration'
            newDocs.push
              _id: object.id
              type: 'school'
              tournament: 'tournament'
              name: object.name
              location: object.location
              small: false
              org_id: object.org_id
              teams: object.teams

          else if object.type == 'Tournament'
            newDocs.push
              _id: 'tournament'
              _rev: @get '_rev'
              type: 'tournament'
              name: object.name

        console.log("New docs: ", newDocs)
        deleteSchoolsAndSave = ->
          App.Store.loadObjectsOfType 'school', (objects) ->
            objectsToDelete = objects.map (obj) ->
              _id: obj._id
              _rev: obj._rev
              _deleted: true
            App.Store.saveBulkDocs objectsToDelete, () ->
              console.log('success deleting old docs')
              App.Store.saveBulkDocs newDocs, ->
                console.log('success with new docs')
                document.location.href = '/teams'

        if blowAwayEverything
          App.Store.loadObjectsOfType 'game', (objects) ->
            objectsToDelete = objects.map (obj) ->
              _id: obj._id
              _rev: obj._rev
              _deleted: true
            App.Store.saveBulkDocs objectsToDelete, () ->
              deleteSchoolsAndSave()
        else
          deleteSchoolsAndSave()

      reader.readAsText(file)