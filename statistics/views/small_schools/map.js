function (doc) {
  if (doc.type && doc.type === 'school' && doc.small) {
    for (var key in doc.teams) {
      emit(key, doc.teams[key].name);
    }
  }
}