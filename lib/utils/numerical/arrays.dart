import 'dart:typed_data';
import 'dart:math' as math;


class Array {
  late Float64List a;

  /// ------- Constructors --------
  
  /// create an array from a Float64List (mostly for internal use)
  Array.from(Float64List b) {
    a = b;
  }

  /// create an array from a list of doubles
  Array.fromList(List<double> l) {
    a = Float64List.fromList(l);
  }

  /// create an array fro a list which is marked as dynamic, but truly only contains doubles
  Array.fromDynamicList(List l) {
    a = Float64List.fromList(List<double>.from(l));
  }

  /// create an array from a list which is marked as dynamic and may contain ints
  Array.fromTrueDynamicList(List l) {
    a = Float64List.fromList(List<double>.from(l.map((i) => i + 0.0)));
  }

  /// creaet an array of length [n] full of zeros
  Array.zeros(int n) {
    a = Float64List(n);
    for (int i = 0; i < n; i++) {
      a[i] = 0.0;
    }
  }

  /// create an array of length [n] full of ones
  Array.ones(int n) {
    a = Float64List(n);
    for (int i = 0; i < n; i++) {
      a[i] = 1.0;
    }
  }

  /// create an array of length [n] full of [value] (equiv to Array.ones(n).scale(value))
  Array.fill(int n, double value) {
    a = Float64List(n);
    for (int i = 0; i < n; i++) {
      a[i] = value;
    }
  }

  /// ------- Getters -------

  int get length => a.length;

  double get sum {
    double out = 0.0;
    for (int i = 0; i < length; i++) {
      out += a[i];
    }
    return out;
  }

  double get max {
    double max = a[0];
    for (int i = 1; i < a.length; i++) {
      if (a[i] > max) {
        max = a[i];
      }
    }
    return max;
  }

  double get min {
    double min = a[0];
    for (int i = 1; i < a.length; i++) {
      if (a[i] < min) {
        min = a[i];
      }
    }
    return min;
  }
  
  int get argmin {
    int argmin = 0;
    for (int i = 1; i < a.length; i++) {
      if (a[i] < a[argmin]) {
        argmin = i;
      }
    }
    return argmin;
  }

  int get argmax {
    int argmax = 0;
    for (int i = 1; i < a.length; i++) {
      if (a[i] > a[argmax]) {
        argmax = i;
      }
    }
    return argmax;
  }

  double get last {
    return a.last;
  }

  double get first {
    return a.first;
  }
  
  double get mean {
    return sum / length;
  }

  Array get abs {
    return Array.fromList(a.map((e) => e.abs()).toList());
  }
  /// ------- Operators -------

  double operator [](int index) => a[index];

  void operator []=(int index, double value) {
    a[index] = value;
  }

  Array operator *(Array b) {
    int minLength = _checkArrayLength(b);
    Float64List c = Float64List(minLength);
    for (int i = 0; i < minLength; i++) {
      c[i] = a[i] * b[i];
    }
    return Array.from(c);
  }

  Array operator /(Array b) {
    int minLength = _checkArrayLength(b);
    Float64List c = Float64List(minLength);
    for (int i = 0; i < minLength; i++) {
      c[i] = a[i] / b[i];
    }
    return Array.from(c);
  }

  Array operator +(Array b) {
    int minLength = _checkArrayLength(b);
    Float64List c = Float64List(minLength);
    for (int i = 0; i < minLength; i++) {
      c[i] = a[i] + b[i];
    }
    return Array.from(c);
  }

  Array operator -(Array b) {
    int minLength = _checkArrayLength(b);
    Float64List c = Float64List(minLength);
    for (int i = 0; i < minLength; i++) {
      c[i] = a[i] - b[i];
    }
    return Array.from(c);
  }

  bool operator ==(dynamic b) {
    if (b.runtimeType != Array) {
      return false;
    }
    else {
      return b.a == a;
    }
  }
  /// -------- Methods -------
  
  Array sublist(int start, [int? end]) {
    return Array.from(a.sublist(start, end));
  }

  Array apply(double Function(double) fun) {
    Float64List c = Float64List(length);
    for (int i = 0; i < length; i++) {
      c[i] = fun(a[i]);
    }
    return Array.from(c);
  }

  Array add(double b) {
    Float64List c = Float64List(length);
    for (int i = 0; i < length; i++) {
      c[i] = a[i] + b;
    }
    return Array.from(c);
  }

  Array scale(double b) {
    Float64List c = Float64List(length);
    for (int i = 0; i < length; i++) {
      c[i] = a[i] * b;
    }
    return Array.from(c);
  }

  bool allEqual(Array b) {
    int minLength = _checkArrayLength(b);
    for (int i = 0; i < minLength; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  double dotProduct(Array b) {
    double out = 0.0;
    for (int i = 0; i < length; i++) {
      out += a[i] * b[i];
    }
    return out;
  }

  Array extend(List<double> l) {
    return Array.fromList(a + l);
  }

  Array extendLeft(List<double> l) {
    return Array.fromList(l + a);
  }

  Array append(double x) {
    a.add(x);
    return this;
  }
  
  int _checkArrayLength(Array b) {
    if (length != b.length) {
      print('both arrays should have the same dimension');
      return math.min(length, b.length);
    }
    return length;
  }
  
  List<double> toList() {
    return List<double>.from(a);
  }

  @override
  String toString() {
    return a.toString();
  }
}

class Matrix {
  late List<Array> m;

  /// ------- Constructors --------

  Matrix.from(List<Array> n) {
    _checkSubArrays(n);
    m = n;
  }

  Matrix.fromLists(List<List<double>> n) {
    m = List<Array>.from(n.map((List<double> b) => Array.fromList(b)).toList());
  }

  Matrix.fromDynamicLists(List<List> n) {
    m = List<Array>.from(n.map((List b) => Array.fromDynamicList(b)).toList());
    _checkSubArrays(m);
  }

  Matrix.fromDynamic(List n) {
    m = List<Array>.from(n.map((dynamic b) => Array.fromDynamicList(b)).toList());
    _checkSubArrays(m);
  }

  /// ------- Getters -------

  List<int> get shape => [m.length, m[0].length];

  int get length => m.length;

  /// ------- Operators -------

  Array operator [](int index) => m[index];

  void operator []=(int index, Array value) {
    m[index] = value;
  }

  Matrix operator *(Matrix n) {
    _checkMatrix(n);
    List<Array> out = <Array>[];
    for (int i = 0; i < length; i++) {
      out.add(m[i] * n[i]);
    }
    return Matrix.from(out);
  }

  Matrix operator /(Matrix n) {
    _checkMatrix(n);
    List<Array> out = <Array>[];
    for (int i = 0; i < length; i++) {
      out.add(m[i] / n[i]);
    }
    return Matrix.from(out);
  }

  Matrix operator +(Matrix n) {
    _checkMatrix(n);
    List<Array> out = <Array>[];
    for (int i = 0; i < length; i++) {
      out.add(m[i] + n[i]);
    }
    return Matrix.from(out);
  }

  Matrix operator -(Matrix n) {
    _checkMatrix(n);
    List<Array> out = <Array>[];
    for (int i = 0; i < length; i++) {
      out.add(m[i] - n[i]);
    }
    return Matrix.from(out);
  }
  
  /// -------- Methods -------

  Matrix apply(double Function(double) fun) {
    List<Array> out = <Array>[];
    for (int i = 0; i < length; i++) {
      out.add(m[i].apply(fun));
    }
    return Matrix.from(out);
  }

  Matrix addVertical(Array a) {
    if (a.length != length) {
      throw ('Array must have same length as matrix shape 0 ($length}), but it is ${a.length}');
    }

    List<Array> out = <Array>[];

    for (int i = 0; i < length; i++) {
      out.add(m[i].add(a[i]));
    }

    return Matrix.from(out);
  }

  Matrix subtractVertical(Array a) {
    if (a.length != length) {
      throw ('Array must have same length as matrix shape 0 ($length}), but it is ${a.length}');
    }

    List<Array> out = <Array>[];

    for (int i = 0; i < length; i++) {
      out.add(m[i].add(-a[i]));
    }

    return Matrix.from(out);
  }

  Matrix multiplyVertical(Array a) {
    if (a.length != length) {
      throw ('Array must have same length as matrix shape 0 ($length}), but it is ${a.length}');
    }

    List<Array> out = <Array>[];

    for (int i = 0; i < length; i++) {
      out.add(m[i].scale(a[i]));
    }

    return Matrix.from(out);
  }

  Matrix divideVertical(Array a) {
    if (a.length != length) {
      throw ('Array must have same length as matrix shape 0 ($length}), but it is ${a.length}');
    }

    List<Array> out = <Array>[];

    for (int i = 0; i < length; i++) {
      out.add(m[i].scale(1 / a[i]));
    }

    return Matrix.from(out);
  }

  Matrix addHorizontal(Array a) {
    if (a.length != shape[1]) {
      throw ('Array must have same length as matrix shape 1 (${shape[1]}), but it is ${a.length}');
    }

    List<Array> out = <Array>[];

    for (int i = 0; i < length; i++) {
      out.add(m[i] + a);
    }

    return Matrix.from(out);
  }

  Matrix subtractHorizontal(Array a) {
    if (a.length != shape[1]) {
      throw ('Array must have same length as matrix shape 1 (${shape[1]}), but it is ${a.length}');
    }

    List<Array> out = <Array>[];

    for (int i = 0; i < length; i++) {
      out.add(m[i] - a);
    }

    return Matrix.from(out);
  }

  Matrix multiplyHorizontal(Array a) {
    if (a.length != shape[1]) {
      throw ('Array must have same length as matrix shape 1 (${shape[1]}), but it is ${a.length}');
    }

    List<Array> out = <Array>[];

    for (int i = 0; i < length; i++) {
      out.add(m[i] * a);
    }

    return Matrix.from(out);
  }

  Matrix divideHorizontal(Array a) {
    if (a.length != shape[1]) {
      throw ('Array must have same length as matrix shape 1 (${shape[1]}), but it is ${a.length}');
    }

    List<Array> out = <Array>[];

    for (int i = 0; i < length; i++) {
      out.add(m[i] / a);
    }

    return Matrix.from(out);
  }

  Array sum([int axis = 0]) {
    if (axis == 0) {
      Array out = m[0];
      for (int i = 1; i < m.length; i++) {
        out = out + m[i];
      }
      return out;
    } else if (axis == 1) {
      return Array.fromList(List<double>.from(m.map((Array a) => a.sum)));
    } else {
      throw ('axis must be 0 or 1');
    }
  }

  Array max([int axis = 0]) {
    if (axis == 0) {
      Array out = m[0];
      for (int i = 1; i < m.length; i++) {
        for (int j = 0; j < m[0].length; j++) {
          if (m[i][j] > out[j]) {
            out[j] = m[i][j];
          }
        }
      }
      return out;
    } else if (axis == 1) {
      return Array.fromList(List<double>.from(m.map((Array a) => a.max)));
    } else {
      throw ('axis must be 0 or 1');
    }
  }

  Array min([int axis = 0]) {
    if (axis == 0) {
      Array out = m[0];
      for (int i = 1; i < m.length; i++) {
        for (int j = 0; j < m[0].length; j++) {
          if (m[i][j] < out[j]) {
            out[j] = m[i][j];
          }
        }
      }
      return out;
    } else if (axis == 1) {
      return Array.fromList(List<double>.from(m.map((Array a) => a.min)));
    } else {
      throw ('axis must be 0 or 1');
    }
  }

  Matrix stackVertical(Matrix n) {
    return Matrix.from(m + n.m);
  }

  void _checkSubArrays(List<Array> n) {
    int len = n[0].length;
    for (int i = 1; i < n.length; i++) {
      if (n[i].length != len) {
        throw ('all arrays need have the same length');
      }
    }
  }

  void _checkMatrix(Matrix n) {
    if (shape[0] != n.shape[0] || shape[1] != n.shape[1]) {
      throw ('both matrices need have the same shape');
    }
  }

  List<List<double>> toList() {
    return m.map((Array a) => a.toList()).toList();
  }

  @override
  String toString() {
    return '${m.map((Array a) =>  '\n' +  a.toString()).toList()}';
  }
}
