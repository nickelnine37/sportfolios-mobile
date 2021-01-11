List<int> range(int n0, [int end, int step]) {
  // mirrors python's range function

  int start;

  if (step == null) {
    step = 1;
  }

  if (end == null) {
    start = 0;
    end = n0;
  } else {
    start = n0;
  }

  int N = (end - start) ~/ step;

  return List.generate(N, (int i) {
    return start + i * step;
  });
}

List<double> linspace(double start, double stop, int N) {
  /// mirrors numpy's np.linspace

  double step = (stop - start) / (N - 1);

  return List.generate(N, (int i) {
    return start + i * step;
  });
}

double dotProduct(List array1, List array2) {

  double total = 0;

  for (int i=0; i<array1.length; i++) {
    total += array1[i] * array2[i];
  }

  return total;

}

List<double> matrixMultiply(List<List<double>> transposedMatrix, List array) {

  List<double> out;
  
  for (int i=0; i<array.length; i++) {

    if (i == 0) {
      out = transposedMatrix[i].map<double>((element) => 1.0 * element * array[i]).toList();
    }

    else {
      for (int j=0; j<transposedMatrix[i].length; j++) {
        out[j] += transposedMatrix[i][j] * array[i];
      }
    }
  }
  
  return out;
}

List<double> zeros(int N) {
    return List.generate(N, (int i) => 0);
}