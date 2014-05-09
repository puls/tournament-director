module.exports =
  map: (doc) ->
    if doc.type and doc.tournament
      emit [doc.tournament, doc.type]
