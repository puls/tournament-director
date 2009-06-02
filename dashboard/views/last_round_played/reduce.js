function (keys, values, rereduce) {
  maxima = [0, 0];
  values.forEach(function (pair) {
    maxima[0] = Math.max(pair[0], maxima[0]);
    maxima[1] = Math.max(pair[1], maxima[1]);
  });
  return maxima;
}
