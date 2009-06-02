function (keys, values, rereduce) {
  min_round = 99999;
  output = [];
  values.forEach(function (pair) {
    if (pair[0] < min_round) {
      min_round = pair[0];
      output = pair;
    }
  });
  return output;
}
