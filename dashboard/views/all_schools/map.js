function (doc) {
  if (doc.type && doc.type === 'school') {

    emit(doc._id, [doc.name, doc.city]);
  }
}
