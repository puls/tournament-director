module.exports =
  map: (doc) ->
    to_id = (name) -> name.toLowerCase().replace /[^a-z0-9]+/g, '_'
    if doc.type
      if doc.type is 'game' and doc.playersEntered
        emit ['match', doc._id], doc
      if doc.type is 'school'
        emit ['registration', doc._id], doc
      if doc.type is 'tournament'
        emit ['tournament', doc._id], doc
