import 'dart:math' as math;
import 'package:sportfolios_alpha/utils/numerical/arrays.dart';

class ArrayLMSR {
  final double b;
  final Array x;
  final bool cash;

  double xMax;
  double expSum;
  Array expX;

  ArrayLMSR({this.x, this.b, this.cash}) {
    if (!cash) {
      xMax = x.max;
      expX = x.apply((double xi) => math.exp((xi - xMax) / b));
      expSum = expX.sum;
    } else {
      if (x.length != 1) {
        throw 'market is cash, but array is not length 1';
      }
    }
  }

  double getValue(Array q, [double k]) {
    if (cash) {
      return k == null ? q[0] : q[0] * k;
    }
    return k == null ? q.dotProduct(expX) / expSum : k * (q.dotProduct(expX) / expSum);
  }

  double _c(Array x_) {
    double xmax = x.max;
    return xmax + b * math.log(x_.apply((double xi) => math.exp((xi - xmax) / b)).sum);
  }

  double priceTrade(Array q, [double k]) {
    if (cash) {
      return k == null ? q[0] : q[0] * k;
    }

    if (k != null) {
      q = q.scale(k);
    }
    return _c(q + x) - xMax - b * math.log(expSum);
  }
}

class MatrixLMSR {
  final Array b;
  final Matrix x;
  final bool cash;

  Array xMax;
  Array expSum;
  Matrix expX;

  MatrixLMSR({this.x, this.b, this.cash}) {
    if (b.length != x.length) {
      throw ('Number of matrix rows need to be the same as length of b');
    }

    xMax = x.max(1);
    expX = x.subtractVertical(xMax).divideVertical(b).apply(math.exp);
    expSum = expX.sum(1);
  }

  Array getValue(Array q, [double k]) {
    if (cash) {
      return k == null ? Array.fill(x.length, q[0]) : Array.fill(x.length, q[0] * k);
    }
    return k == null
        ? expX.multiplyHorizontal(q).sum(1) / expSum
        : (expX.multiplyHorizontal(q).sum(1) / expSum).scale(k);
  }
}

void main() {
  Matrix x = Matrix.fromDynamicLists([
    [1, 2, 3, 4, 5],
    [5, 4, 3, 2, 1],
    [5, 4, 6, 3, 2]
  ]);

  print(x);

  Array b = Array.fromDynamicList([3, 4, 5]);

  MatrixLMSR lmsr = MatrixLMSR(x: x, b: b, cash: false);

  print(lmsr.getValue(Array.fromDynamicList([1, 2, 3, 2, 1])));

  print(ArrayLMSR(
    x: Array.fromDynamicList([1, 2, 3, 4, 5]),
    b: 3,
    cash: false,
  ).getValue(Array.fromDynamicList([1, 2, 3, 2, 1])));
}
