import 'dart:math' as math;


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

List<double> matrixMultiplyDoubleDouble (List<List<double>> transposedMatrix, List<double> array) {

  List<double> out = transposedMatrix[0].map<double>((element) => element * array[0]).toList();
  
  for (int i=1; i<array.length; i++) {

  for (int j=0; j<transposedMatrix[i].length; j++) {
          out[j] += transposedMatrix[i][j] * array[i];
        }
    
  }
  
  return out;
}


List<double> matrixMultiplyIntDouble (List<List<int>> transposedMatrix, List<double> array) {

  List<double> out = transposedMatrix[0].map<double>((element) => element * array[0]).toList();
  
  for (int i=1; i<array.length; i++) {

  for (int j=0; j<transposedMatrix[i].length; j++) {
          out[j] += transposedMatrix[i][j] * array[i];
        }
    
  }
  
  return out;
}

List<double> matrixMultiply(List<List<dynamic>> transposedMatrix, List array) {

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

List<double> ones(int N) {
    return List.generate(N, (int i) => 1);
}

List<double> ns(int N, double n) {
    return List.generate(N, (int i) => n);
}


double getMax (List<double> y) {
  return y.reduce(math.max);
}

int argMax (List<double> y) {
  return range(y.length).reduce((prev, cur) => y[prev] > y[cur] ? prev : cur);
}

dynamic getSum (List y) {
  return y.fold(0, (p, c) => p + c);
}