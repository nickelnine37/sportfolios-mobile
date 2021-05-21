import 'dart:collection';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/data/firebase/markets.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/numbers.dart';


class Market {
  
  // ----- basic attributes -----
  String id;
  String name;
  DocumentSnapshot doc;
  List<String> searchTerms;

  // -----  Link attributes -----
  String team;            // null for teams
  List<String> players;   // null for players

  // ----- Visual attributes -----
  String info1;
  String info2;
  String info3;
  List<String> colours;
  String imageURL;

  // ----- LMSR attributes ------
  // length of quantity vector
  int n;    

  // back attributes 
  double currentBackValue;     
  LinkedHashMap<int, double> dailyBackValue;

  // current holdings
  DateTime currentHoldingsLastUpdated;
  List<double> currentHolding;
  List<double> currentHoldingExp;
  double currentHoldingMax;
  double currentHoldingExpSum;
  double currentB;

  // historical holdings
  Map<String, LinkedHashMap<int, List>> historicalHoldings = Map<String, LinkedHashMap<int, List>>();
  Map<String, LinkedHashMap<int, List>> historicalHoldingsExp = Map<String, LinkedHashMap<int, List>>();
  Map<String, LinkedHashMap<int, double>> historicalHoldingMax = Map<String, LinkedHashMap<int, double>>();
  Map<String, LinkedHashMap<int, double>> historicalHoldingExpSum = Map<String, LinkedHashMap<int, double>>();
  Map<String, LinkedHashMap<int, double>> historicalB = Map<String, LinkedHashMap<int, double>>();

  Market(this.id);

  /// takes in a hash map between unix timestamps and values
  /// and returns the linked hash map equiv, where the times
  /// have been sorted
  LinkedHashMap<int, double> sortPriceTimeMap(Map values) {
    List times = values.keys.toList(growable: false);
    LinkedHashMap<int, double> out = LinkedHashMap<int, double>();
    times.sort();
    times.forEach((k1) {
      out[int.parse(k1)] = 0.0 + values[k1];
    });
    return out;
  }

  /// same but for a hash map between timestamps and arrays
  LinkedHashMap<int, List> sortHoldingsTimeMap(Map values) {
    List times = values.keys.toList(growable: false);
    LinkedHashMap<int, List> out = LinkedHashMap<int, List>();
    times.sort();
    times.forEach((k1) {
      out[int.parse(k1)] = values[k1];
    });
    return out;
  }
  
  /// helper function for setting some back properties which are required
  /// to display the mini graph and scroll prices
  void setBackProperties(double currentValue, Map dailyValue) {
    currentBackValue = currentValue;
    dailyBackValue = sortPriceTimeMap(dailyValue);
  }

  /// initialise a market given a firebase snapshot
  Market.fromDocumentSnapshotAndPrices(DocumentSnapshot snapshot) {
    id = snapshot.id;
    Map<String, dynamic> data = snapshot.data();
    doc = snapshot;


    colours = List<String>.from(data['colours']);

    if (snapshot.id[snapshot.id.length - 1] == 'P') {

      if (data['name'].length > 24) {
        List names = data['name'].split(" ");
        if (names.length > 2)
          name = names[0] + ' ' + names[names.length - 1];
        else
          name = names[names.length - 1];
      } else
        name = data['name'];

      info1 = data['country_flag'] + ' ' + data['position'];
      info2 = "${data['rating']}";

      if (data['team'].length > 20)
        info3 = data['team'].split(" ")[0];
      else
        info3 = data['team'];

      team = data['team'];
    } else {
      name = data['team_name'];
      info1 = "P ${data['played']}";
      info2 = "GD ${data['goal_difference'] > 0 ? '+' : '-'}${data['goal_difference'].abs()}";
      info3 = "PTS ${data['points']}";
    }

    searchTerms = data['search_terms'].cast<String>();
    imageURL = data['image'];
  }

  Future<void> updateCurrentHoldings() async {
    Map<String, dynamic> holdings = await getcurrentHoldings(id);
    if (holdings == null) {
      print('Error fetuing current holdings');
    } else {
      setCurrentHolding(List<double>.from(holdings['x']), holdings['b']);
    }
  }

  Future<void> updateHistoricalHoldings() async {
    Map<String, dynamic> histHoldings = await getHistoricalHoldings(id);

    if (histHoldings == null) {
      print('Error fetching historical holdings');
    } else {
      setHistoricalHoldings(histHoldings['xhist'], histHoldings['bhist']);
    }
  }

  void setCurrentHolding(List<double> holding, dynamic b) {
    currentHolding = holding;
    currentB = b + 0.0;
    currentHoldingMax = getMax(holding);
    currentHoldingExp =
        currentHolding.map((double i) => math.exp((i - currentHoldingMax) / currentB)).toList();
    currentHoldingExpSum = getSum(currentHoldingExp);
    n = holding.length;
    currentHoldingsLastUpdated = DateTime.now();
  }

  void setHistoricalHoldings(Map xhist, Map bhist) {
    bhist.keys.forEach((th) {
      historicalB[th] = sortPriceTimeMap(bhist[th]);
    });

    xhist.keys.forEach((th) {
      historicalHoldings[th] = sortHoldingsTimeMap(xhist[th]);
      historicalHoldingMax[th] = LinkedHashMap.fromIterables(historicalHoldings[th].keys,
          historicalHoldings[th].values.map((array) => getMax(List<double>.from(array))));
      historicalHoldingsExp[th] = LinkedHashMap.fromIterables(
          historicalHoldings[th].keys,
          historicalHoldings[th].keys.map((t) => historicalHoldings[th][t]
              .map((i) => math.exp((i - historicalHoldingMax[th][t]) / historicalB[th][t]))
              .toList()));
      historicalHoldingExpSum[th] = LinkedHashMap.fromIterables(historicalHoldings[th].keys,
          historicalHoldings[th].keys.map((t) => getSum(historicalHoldingsExp[th][t])));
    });
  }

  double getCurrentValue(List<double> q) {
    return round(dotProduct(q, currentHoldingExp) / currentHoldingExpSum, 6);
  }

  Map<String, LinkedHashMap<int, double>> getHistoricalValue(List<double> q) {
    Map<String, LinkedHashMap<int, double>> out = Map<String, LinkedHashMap<int, double>>();
    historicalHoldingsExp.keys.forEach((th) {
      out[th] = LinkedHashMap.fromIterables(
          historicalHoldingsExp[th].keys,
          historicalHoldingsExp[th].keys.map(
              (t) => round(dotProduct(q, historicalHoldingsExp[th][t]) / historicalHoldingExpSum[th][t], 6)));
    });
    return out;
  }

  double c(List<double> x) {
    double xmax = getMax(x);
    return xmax + currentB * math.log(getSum(x.map((xi) => math.exp((xi - xmax) / currentB)).toList()));
  }

  double priceTrade(List<double> q, double k) {
    return c(range(n).map((i) => currentHolding[i] + k * q[i]).toList()) - c(currentHolding);
  }

  @override
  String toString() {
    return 'Market($id)';
  }
}

