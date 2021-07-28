import 'dart:math' as math;
import 'dart:math';
import '../../utils/numerical/array_operations.dart';
import '../../utils/numerical/arrays.dart';

/// Used as the argument for any pricing-type method. Represents a holding of
/// some asset, either a classic LMSR vector with optional scaling constant,
/// or an amount of longs/shorts.
class Asset {
  Array? q;
  double? k;
  bool? long;

  /// for team-type methods. [qq] is the quantity vector, [kk] is a scaling constant
  Asset.team(Array qq, [double? kk]) {
    q = qq;
    k = kk;
  }

  /// for player-type methods. [llong] represents the long/short contract. [kk] is the number
  /// of longs/shorts
  Asset.player(bool llong, [double? kk]) {
    long = llong;
    k = kk;
  }
}

/// Base class for one-off LMSR calculations
abstract class LMSR {
  int? vecLen;
  double getValue(Asset asset);
  double getLongValue();
  double priceTrade(Asset asset);
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
    qLong = qLong = Array.fromList(range(x.length).map((int i) => math.exp(-i / 6)).toList().reversed.toList());
    _xMax = x.max;
    _expX = x.apply((double xi) => math.exp((xi - _xMax) / b));
    _expSum = _expX.sum;
    vecLen = x.length;
  }

  @override
  double getLongValue() {
    return getValue(Asset.team(qLong, 10.0));
  }

  @override
  double getValue(Asset asset) {
    return asset.k == null ? asset.q!.dotProduct(_expX) / _expSum : asset.k! * (asset.q!.dotProduct(_expX) / _expSum);
  }

  double _c(Array x_) {
    double xmax = x.max;
    return xmax + b * math.log(x_.apply((double xi) => math.exp((xi - xmax) / b)).sum);
  }

  @override
  double priceTrade(Asset asset) {
    if (asset.k != null) {
      asset.q = asset.q!.scale(asset.k!);
    }
    double out = _c(asset.q! + x) - _xMax - b * math.log(_expSum);
    
    if (out > 0) {
      return max(out, 0.01);
    }
    else {
      return out;
    }

  }
}

/// Player class for one-off LMSR calculations. Implements Long/Short LMSR scheme.
/// Initialised with  double N and  double b
class PlayerLMSR extends LMSR {
  late double n;
  late double b;

  PlayerLMSR({required double this.n, required double this.b});

  @override
  double getLongValue() {
    return getValue(Asset.player(true, 10));
  }

  @override
  double getValue(Asset asset) {
    if (asset.k == null) {
      asset.k = 1.0;
    }

    if (!asset.long!) {
      return asset.k! - getValue(Asset.player(true, asset.k));
    }

    double c = n / b;

    if (c == 0) return 0.5;

    if (c > 0)
      return asset.k! * ((c - 1) + math.exp(-c)) / (c * (1 - math.exp(-c)));
    else
      return asset.k! * (math.exp(c) * (c - 1) + 1) / (c * (math.exp(c) - 1));
  }

  @override
  double priceTrade(Asset asset) {
    if (asset.k == null) {
      asset.k = 1.0;
    }

    if (!asset.long!) return asset.k! + priceTrade(Asset.player(true, -asset.k!));

    if (asset.k! == 0)
      return 0;
    else if (n == 0) {
      if (asset.k! < 0)
        return b * math.log(b * (math.exp(asset.k! / b) - 1) / asset.k!);
      else
        return b * math.log(b * (1 - math.exp(-asset.k! / b)) / (asset.k! * math.exp(-n / b)));
    } else if (n < 0) {
      if (n == -asset.k!)
        return b * math.log(n / (b * (math.exp(n / b) - 1)));
      else
        return b * math.log(n / (n + asset.k!) * (math.exp((n + asset.k!) / b) - 1) / (math.exp(n / b) - 1));
    } else {
      if (n == -asset.k!)
        return b * math.log(n * math.exp(-n / b) / (b * (1 - math.exp(-n / b))));
      else
        return b * math.log(n / (n + asset.k!) * (math.exp(asset.k! / b) - math.exp(-n / b)) / (1 - math.exp(-n / b)));
    }
  }
}

/// Base class for vector LMSR calculations. This class and derivatives
/// are not aware of their associated time, and never exist independently of
/// a historicalLMSR class
abstract class MultiLMSR {
  Array getValue(Asset asset);
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
  Array getValue(Asset asset) {
    return asset.k == null
        ? _expX.multiplyHorizontal(asset.q!).sum(1) / _expSum
        : (_expX.multiplyHorizontal(asset.q!).sum(1) / _expSum).scale(asset.k!);
  }
}

/// Player class for vector LMSR calculations. Implements Long/Short LMSR scheme.
/// Initialised with Array N and Array b
class PlayerMultiLMSR extends MultiLMSR {
  late Array n;
  late Array b;
  late Array c;

  PlayerMultiLMSR({required this.n, required this.b}) {
    c = n / b;
  }

  double longShortPrice(double cc) {
    if (cc == 0) return 0.5;

    if (cc > 0)
      return ((cc - 1) + math.exp(-cc)) / (cc * (1 - math.exp(-cc)));
    else
      return (math.exp(cc) * (cc - 1) + 1) / (cc * (math.exp(cc) - 1));
  }

  @override
  Array getValue(Asset asset) {
    if (asset.k == null) asset.k = 1.0;

    if (!asset.long!)
      return Array.fill(n.length, asset.k!) - getValue(Asset.player(true, asset.k!));
    else
      return c.apply(longShortPrice).scale(asset.k!);
  }
}

/// Base class for historical LMSR calculations. This amounts to a series
/// of vector calculations for different time horizons. Must also come
/// with assoicated time stamps
abstract class HistoricalLMSR {
  late Map<String, MultiLMSR> lmsrMap;
  late Map<String, List<int>> ts;
  Map<String, Array> getHistoricalValue(Asset asset);
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

  @override
  Map<String, Array> getHistoricalValue(Asset asset) {
    return Map<String, Array>.fromIterables(
      lmsrMap.keys,
      lmsrMap.keys.map(
        (String th) => lmsrMap[th]!.getValue(asset),
      ),
    );
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
        nhist.keys, nhist.keys.map((String th) => PlayerMultiLMSR(n: nhist[th]!, b: bhist[th]!)));
    ts = thist;
  }

  @override
  Map<String, Array> getHistoricalValue(Asset asset) {
    return Map<String, Array>.fromIterables(lmsrMap.keys, lmsrMap.keys.map((String th) => lmsrMap[th]!.getValue(asset)));
  }
}
