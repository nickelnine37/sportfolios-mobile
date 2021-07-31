import 'dart:math' as math;
import '../../utils/numerical/array_operations.dart';
import '../../utils/numerical/arrays.dart';

/// Used as the argument for any pricing-type method. Represents a holding of
/// some asset, either a classic LMSR vector with optional scaling constant,
/// or an amount of longs/shorts.
// class Asset {
//   Array? q;
//   double? k;
//   bool? long;

//   /// for team-type methods. [qq] is the quantity vector, [kk] is a scaling constant
//   Asset.team(Array qq, [double? kk]) {
//     q = qq;
//     k = kk;
//   }

//   /// for player-type methods. [llong] represents the long/short contract. [kk] is the number
//   /// of longs/shorts
//   Asset.player(bool llong, [double? kk]) {
//     long = llong;
//     k = kk;
//   }
//   @override
//   String toString() {
//     return 'Asset(q=${q}, long=${long}, k=${k})';
//   }
// }

/// Base class for one-off LMSR calculations
abstract class LMSR {
  int? vecLen;
  double getValue(Array quantity);
  double getLongValue();
  double priceTrade(Array quantity);
}

/// Team class for one-off LMSR calculations. Implements classic LMSR scheme.
/// Initialised with Array x and double b
class TeamLMSR extends LMSR {
  late double b;
  late Array x;
  late Array qLong;

  late double _xMax;
  late double _expSum;
  late Array _expX;

  TeamLMSR({required Array this.x, required double this.b}) {
    qLong = qLong = Array.fromList(range(x.length).map((int i) => 10 * math.exp(-i / 6)).toList().reversed.toList());
    _xMax = x.max;
    _expX = x.apply((double xi) => math.exp((xi - _xMax) / b));
    _expSum = _expX.sum;
    vecLen = x.length;
  }

  @override
  double getLongValue() {
    return getValue(qLong);
  }

  @override
  double getValue(Array quantity) {
    return quantity.dotProduct(_expX) / _expSum;
  }

  double _c(Array x_) {
    double xmax = x.max;
    return xmax + b * math.log(x_.apply((double xi) => math.exp((xi - xmax) / b)).sum);
  }

  @override
  double priceTrade(Array quantity) {
    double out = _c(quantity + x) - _xMax - b * math.log(_expSum);

    if (out > 0) {
      return math.max(out, 0.01);
    } else {
      return out;
    }
  }
}

/// Player class for one-off LMSR calculations. Implements Long/Short LMSR scheme.
/// Initialised with  double N and  double b
class PlayerLMSR extends LMSR {
  late double n;
  late double b;
  late double lp;

  PlayerLMSR({required double this.n, required double this.b}) {
    double k = n / b;
    if (k == 0) lp = 0.5;
    if (k > 0)
      lp = ((k - 1) + math.exp(-k)) / (k * (1 - math.exp(-k)));
    else
      lp = (math.exp(k) * (k - 1) + 1) / (k * (math.exp(k) - 1));
  }

  @override
  double getLongValue() {
    return getValue(Array.fromList(<double>[10.0, 0.0]));
  }

  @override
  double getValue(Array quantity) {
    double cMin = quantity.min;
    double cMax = quantity.max;
    if (quantity.argmax == 0)
      return cMin + lp * (cMax - cMin);
    else
      return cMax - lp * (cMax - cMin);
  }

  double _priceLongTrade(double nLongs) {
    if (nLongs == 0)
      return 0;
    else if (n == 0) {
      if (nLongs < 0)
        return b * math.log(b * (math.exp(nLongs / b) - 1) / nLongs);
      else
        return b * math.log(b * (1 - math.exp(-nLongs / b)) / (nLongs * math.exp(-n / b)));
    } else if (n < 0) {
      if (n == -nLongs)
        return b * math.log(n / (b * (math.exp(n / b) - 1)));
      else
        return b * math.log(n / (n + nLongs) * (math.exp((n + nLongs) / b) - 1) / (math.exp(n / b) - 1));
    } else {
      if (n == -nLongs)
        return b * math.log(n * math.exp(-n / b) / (b * (1 - math.exp(-n / b))));
      else
        return b * math.log(n / (n + nLongs) * (math.exp(nLongs / b) - math.exp(-n / b)) / (1 - math.exp(-n / b)));
    }
  }

  @override
  double priceTrade(Array quantity) {
    return _priceLongTrade(quantity[0]) + quantity[1] + _priceLongTrade(quantity[1]);
  }
}

/// Base class for vector LMSR calculations. This class and derivatives
/// are not aware of their associated time, and never exist independently of
/// a historicalLMSR class
abstract class MultiLMSR {
  Array getValue(Array quantity);
}

/// Team class for vector LMSR calculations. Implements classic LMSR scheme.
/// Initialised with Matrix x and Array b
class TeamMultiLMSR extends MultiLMSR {
  late Matrix x;
  late Array b;

  late Array _xMax;
  late Array _expSum;
  late Matrix _expX;

  TeamMultiLMSR({required this.x, required this.b}) {
    _xMax = x.max(1);
    _expX = x.subtractVertical(_xMax).divideVertical(b).apply(math.exp);
    _expSum = _expX.sum(1);
  }

  @override
  Array getValue(Array quantity) {
    return _expX.multiplyHorizontal(quantity).sum(1) / _expSum;
  }
}

/// Player class for vector LMSR calculations. Implements Long/Short LMSR scheme.
/// Initialised with Array N and Array b
class PlayerMultiLMSR extends MultiLMSR {
  late Array n;
  late Array b;
  late Array lp;

  PlayerMultiLMSR({required this.n, required this.b}) {
    Array k = n / b;
    lp = k.apply(_longPrice);
  }

  double _longPrice(double kk) {
    if (kk == 0) return 0.5;

    if (kk > 0)
      return ((kk - 1) + math.exp(-kk)) / (kk * (1 - math.exp(-kk)));
    else
      return (math.exp(kk) * (kk - 1) + 1) / (kk * (math.exp(kk) - 1));
  }

  @override
  Array getValue(Array quantity) {
    double cMin = quantity.min;
    double cMax = quantity.max;
    if (quantity.argmax == 0)
      return lp.scale(cMax - cMin).add(cMin);
    else
      return lp.scale(cMin - cMax).add(cMax);
  }
}

/// Base class for historical LMSR calculations. This amounts to a series
/// of vector calculations for different time horizons. Must also come
/// with assoicated time stamps
abstract class HistoricalLMSR {
  late Map<String, MultiLMSR> lmsrMap;
  late Map<String, List<int>> ts;

  Map<String, Array> getHistoricalValue(Array quantity) {
    return Map<String, Array>.fromIterables(
      lmsrMap.keys,
      lmsrMap.keys.map(
        (String th) => lmsrMap[th]!.getValue(quantity),
      ),
    );
  }
}

/// Team class for historical LMSR calculations. Initialied with Map<String, Matrix>
/// xhist, Map<String, Array> bhist and Map<String, List<int>> thist.
class TeamHistoricalLMSR extends HistoricalLMSR {
  TeamHistoricalLMSR({
    required Map<String, Matrix> xhist,
    required Map<String, Array> bhist,
    required Map<String, List<int>> thist,
  }) {
    lmsrMap = Map<String, TeamMultiLMSR>.fromIterables(
      xhist.keys,
      xhist.keys.map(
        (String th) => TeamMultiLMSR(x: xhist[th]!, b: bhist[th]!),
      ),
    );
    ts = thist;
  }
}

/// Player class for histrical LMSR calculations Initialied with Map<String, Array>
/// nhist, Map<String, Array> bhist and Map<String, List<int>> thist.
class PlayerHisoricalLMSR extends HistoricalLMSR {
  PlayerHisoricalLMSR({
    required Map<String, Array> nhist,
    required Map<String, Array> bhist,
    required Map<String, List<int>> thist,
  }) {
    lmsrMap = Map<String, PlayerMultiLMSR>.fromIterables(
      nhist.keys,
      nhist.keys.map(
        (String th) => PlayerMultiLMSR(n: nhist[th]!, b: bhist[th]!),
      ),
    );
    ts = thist;
  }
}
