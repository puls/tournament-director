function (doc) {
  if (doc.type && doc.type === 'school') {
    emit(doc.name, doc);
  }
}
