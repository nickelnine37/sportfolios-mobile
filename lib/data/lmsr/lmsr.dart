import 'dart:math' as math;
import 'package:sportfolios_alpha/data/api/requests.dart';
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

class MarketLMSR {
  String market;
  bool cash;
  int n;

  ArrayLMSR currentLMSR;
  DateTime currentLatUpdated;

  Map<String, MatrixLMSR> historicalLMSR = Map<String, MatrixLMSR>();
  DateTime historicalLastUpdated;
  Map<String, List<int>> times;

  int updateInterval = 30;

  MarketLMSR(this.market) {
    cash = market == 'cash';
  }

  Future<void> updateCurrentX() async {
    if (currentLatUpdated == null ||
        DateTime.now().difference(currentLatUpdated).inSeconds > updateInterval) {
      Map<String, dynamic> holdings = await getcurrentX(market);
      currentLatUpdated = DateTime.now();
      currentLMSR = ArrayLMSR(
        x: Array.fromList(List<double>.from(holdings['x'])),
        b: holdings['b'] + 0.0,
        cash: cash,
      );
      n = holdings['x'].length;
    }
  }

  void setCurrentX(List x, double b) {
    currentLatUpdated = DateTime.now();
    currentLMSR = ArrayLMSR(
      x: Array.fromList(List<double>.from(x)),
      b: b,
      cash: cash,
    );
  }

  Future<void> updateHistoricalX() async {
    if (historicalLastUpdated == null ||
        DateTime.now().difference(historicalLastUpdated).inSeconds > updateInterval) {
      Map<String, dynamic> historicalHoldings = await getHistoricalX(market);
      historicalLastUpdated = DateTime.now();
    Map<String, dynamic> xhist = historicalHoldings['data']['x'];
      Map<String, dynamic> bhist = historicalHoldings['data']['b'];
      times = historicalHoldings['time'];

      for (String th in xhist.keys) {
        historicalLMSR[th] =
            MatrixLMSR(x: Matrix.fromLists(xhist[th]), b: Array.fromList(bhist[th]), cash: cash);
      }
    }
  }

  void setHistoricalX(Map<String, dynamic> x, Map<String, dynamic> b) {
    Map<String, List<List<double>>> xhist = Map<String, List<List<double>>>.from(x);
    Map<String, List<double>> bhist = Map<String, List<double>>.from(b);
      for (String th in xhist.keys) {
        historicalLMSR[th] =
            MatrixLMSR(x: Matrix.fromLists(xhist[th]), b: Array.fromList(bhist[th]), cash: cash);
      }
  }

  double getValue(List<double> q, [double k]) {
    if (currentLMSR == null) {
      print('Cannot getValue : currentLMSR has not been set (try calling updateCurrentX)');
      return null;
    }

    return currentLMSR.getValue(Array.fromList(q), k);
  }

  Map<String, List<double>> getHistoricalValue(List<double> q, [double k]) {
    if (historicalLMSR == null) {
      print('Cannot getValue : historicalLMSR has not been set (try calling updateHistoricalX)');
      return null;
    }

    return Map<String, List<double>>.fromIterables(
      historicalLMSR.keys,
      historicalLMSR.keys.map((String th) => historicalLMSR[th].getValue(Array.fromList(q), k).toList()),
    );
  }

  double priceTrade(List<double> q, [double k]) {
    return currentLMSR.priceTrade(Array.fromList(q), k);
  }
}
