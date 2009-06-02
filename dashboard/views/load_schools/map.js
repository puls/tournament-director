function (doc) {
  if (doc.type && doc.type === 'school') {

    emit(null, doc);
  }
}
