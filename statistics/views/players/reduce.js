function (keys, values, rereduce) {
  var output = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  values.forEach(function (row) {
    for (var i = 0; i < row.length; i++) {
      output[i] += row[i];
    }
  });
  
  // gp
  output[1] = output[10] * output[2] / output[0];

  // pp20
  output[7] = 20 * output[6] / output[2];
  
  // tu/neg
  output[8] = (output[5] == 0 ? 0 : (output[3] + output[4]) / output[5]);
  
  // neg/20
  output[9] = 20 * output[5] / output[2];

  return output;
}