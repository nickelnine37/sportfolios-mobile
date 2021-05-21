import 'dart:collection';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/numbers.dart';

class Market {
  // ----- basic attributes -----
  String id;
  String name;
  DocumentSnapshot doc;
  List<String> searchTerms;

  // -----  Link attributes -----
  String team; // null for teams
  List<String> players; // null for players

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
  DateTime currentXLastUpdated;
  List<double> currentX;
  List<double> currentExpX;
  double currentMaxX;
  double currentExpXSum;
  double currentB;

  // historical holdings
  Map<String, LinkedHashMap<int, List>> historicalX = Map<String, LinkedHashMap<int, List>>();
  Map<String, LinkedHashMap<int, List>> historicalExpX= Map<String, LinkedHashMap<int, List>>();
  Map<String, LinkedHashMap<int, double>> historicalMaxX = Map<String, LinkedHashMap<int, double>>();
  Map<String, LinkedHashMap<int, double>> historicalExpXSum = Map<String, LinkedHashMap<int, double>>();
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
  LinkedHashMap<int, List> sortXTimeMap(Map values) {
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

  /// initialise player info from firebase data
  void initPlayerInfo(Map<String, dynamic> data) {
    if (data['name'].length > 24) {
      List names = data['name'].split(" ");
      if (names.length > 2)
        name = names.first + ' ' + names.last;
      else
        name = names.last;
    } else
      name = data['name'];

    info1 = data['country_flag'] + ' ' + data['position'];
    info2 = "${data['rating']}";

    if (data['team'].length > 20)
      info3 = data['team'].split(" ")[0];
    else
      info3 = data['team'];
    team = data['team'];
  }
  
  /// initialise team info from firebase data
  void initTeamInfo(Map<String, dynamic> data) {
    name = data['name'];
    info1 = "P ${data['played']}";
    info2 = "GD ${data['goal_difference'] > 0 ? '+' : '-'}${data['goal_difference'].abs()}";
    info3 = "PTS ${data['points']}";
    players = data['players'];
  }

  /// initialise a market from a firebase snapshot
  Market.fromDocumentSnapshotAndPrices(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();

    id = snapshot.id;
    doc = snapshot;

    colours = List<String>.from(data['colours']);
    searchTerms = List<String>.from(data['search_terms']);
    imageURL = data['image'];

    if (snapshot.id[snapshot.id.length - 1] == 'P') {
      initPlayerInfo(data);
    } else {
      initTeamInfo(data);
    }
  }

  /// query the server for current market 
  Future<void> updateCurrentX() async {
    Map<String, dynamic> holdings = await getcurrentX(id);
    if (holdings == null) {
      print('Error fetuing current holdings');
    } else {
      setCurrentX(List<double>.from(holdings['x']), holdings['b']);
    }
  }

  Future<void> updateHistoricalX() async {
    Map<String, dynamic> histX = await getHistoricalX(id);

    if (histX == null) {
      print('Error fetching historical holdings');
    } else {
      setHistoricalX(histX['xhist'], histX['bhist']);
    }
  }

  void setCurrentX(List<double> holding, dynamic b) {
    currentX = holding;
    currentB = b + 0.0;
    currentMaxX = getMax(holding);
    currentExpX =
        currentX.map((double i) => math.exp((i - currentMaxX) / currentB)).toList();
    currentExpXSum = getSum(currentExpX);
    n = holding.length;
    currentXLastUpdated = DateTime.now();
  }

  void setHistoricalX(Map xhist, Map bhist) {
    bhist.keys.forEach((th) {
      historicalB[th] = sortPriceTimeMap(bhist[th]);
    });

    xhist.keys.forEach((th) {
      historicalX[th] = sortXTimeMap(xhist[th]);
      historicalMaxX[th] = LinkedHashMap.fromIterables(historicalX[th].keys,
          historicalX[th].values.map((array) => getMax(List<double>.from(array))));
      historicalExpX[th] = LinkedHashMap.fromIterables(
          historicalX[th].keys,
          historicalX[th].keys.map((t) => historicalX[th][t]
              .map((i) => math.exp((i - historicalMaxX[th][t]) / historicalB[th][t]))
              .toList()));
      historicalExpXSum[th] = LinkedHashMap.fromIterables(historicalX[th].keys,
          historicalX[th].keys.map((t) => getSum(historicalExpX[th][t])));
    });
  }

  double getCurrentValue(List<double> q) {
    return round(dotProduct(q, currentExpX) / currentExpXSum, 6);
  }

  Map<String, LinkedHashMap<int, double>> getHistoricalValue(List<double> q) {
    Map<String, LinkedHashMap<int, double>> out = Map<String, LinkedHashMap<int, double>>();
    historicalExpX.keys.forEach((th) {
      out[th] = LinkedHashMap.fromIterables(
          historicalExpX[th].keys,
          historicalExpX[th].keys.map(
              (t) => round(dotProduct(q, historicalExpX[th][t]) / historicalExpXSum[th][t], 6)));
    });
    return out;
  }

  double c(List<double> x) {
    double xmax = getMax(x);
    return xmax + currentB * math.log(getSum(x.map((xi) => math.exp((xi - xmax) / currentB)).toList()));
  }

  double priceTrade(List<double> q, double k) {
    return c(range(n).map((i) => currentX[i] + k * q[i]).toList()) - c(currentX);
  }

  @override
  String toString() {
    return 'Market($id)';
  }
}
