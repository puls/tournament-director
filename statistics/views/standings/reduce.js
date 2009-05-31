function (keys, values, rereduce) {
  var output = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  values.forEach(function (row) {
    for (var i = 0; i < row.length; i++) {
      output[i] += row[i];
    }
  });
  
  var games = output[0] + output[1];
  
  // pct
  output[2] = output[0] / games;
  
  // pfpg
  output[4] = output[3] / games;
  
  // papg
  output[6] = output[5] / games;
  
  // pp20
  output[8] = 20 * output[3] / output[7];
  return output;
}