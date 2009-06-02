function (doc) {
  if (doc.type && doc.type === 'game') {
    if (doc.entry_complete && !doc.indivs_complete) {
      emit(doc._id, doc);
    }
  }
}
