import 'dart:collection';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/numbers.dart';

/// takes in a hash map between unix timestamps and values
/// and returns the linked hash map equiv, where the times
/// have been sorted
// LinkedHashMap<int, double> sortPriceTimeMap(Map values) {
//   List times = values.keys.toList(growable: false);
//   LinkedHashMap<int, double> out = LinkedHashMap<int, double>();
//   times.sort();
//   times.forEach((k1) {
//     out[int.parse(k1)] = 0.0 + values[k1];
//   });
//   return out;
// }

/// same but for a hash map between timestamps and arrays
// SplayTreeMap<int, List> sortXTimeMap(Map values) {
//   List times = values.keys.toList(growable: false);
//   LinkedHashMap<int, List> out = LinkedHashMap<int, List>();
//   times.sort();
//   times.forEach((k1) {
//     out[int.parse(k1)] = values[k1];
//   });
//   return out;
// }

class Market {
  // ----- basic attributes -----
  String id;
  String name;
  DocumentSnapshot doc;
  List<String> searchTerms;
  DateTime startDate;
  DateTime endDate;

  // stats
  Map<String, dynamic> stats;

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
  SplayTreeMap<int, double> dailyBackValue;

  // current holdings
  DateTime currentXLastUpdated;
  List<double> currentX;
  List<double> currentExpX;
  double currentMaxX;
  double currentExpXSum;
  double currentB;

  // historical holdings
  Map<String, SplayTreeMap<int, List>> historicalX = Map<String, SplayTreeMap<int, List>>();
  Map<String, SplayTreeMap<int, List>> historicalExpX = Map<String, SplayTreeMap<int, List>>();
  Map<String, SplayTreeMap<int, double>> historicalMaxX = Map<String, SplayTreeMap<int, double>>();
  Map<String, SplayTreeMap<int, double>> historicalExpXSum = Map<String, SplayTreeMap<int, double>>();
  Map<String, SplayTreeMap<int, double>> historicalB = Map<String, SplayTreeMap<int, double>>();

  /// initialise market from id
  Market(this.id) {
    if (id == 'cash') {
      name = 'Cash';
    }
  }

  /// initialise a market from a firebase snapshot
  Market.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();

    id = snapshot.id;
    doc = snapshot;

    colours = List<String>.from(data['colours']);
    searchTerms = List<String>.from(data['search_terms']);
    imageURL = data['image'];
    startDate = data['start_date'].toDate();
    endDate = data['end_date'].toDate();

    if (snapshot.id[snapshot.id.length - 1] == 'P') {
      initPlayerInfo(data);
    } else {
      initTeamInfo(data);
    }
  }

  Future<void> getStats() async {
    String idStats = id.split(':')[0] + id[id.length - 1];
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('stats')
      .doc(idStats)
      .get();
    print(snapshot);
    stats = snapshot.data();
    print(stats);
  }


  void addDocumentSnapshotData(DocumentSnapshot snapshot) {
    assert(id == snapshot.id);

    Map<String, dynamic> data = snapshot.data();

    doc = snapshot;

    colours = List<String>.from(data['colours']);
    searchTerms = List<String>.from(data['search_terms']);
    imageURL = data['image'];
    startDate = data['start_date'].toDate();
    endDate = data['end_date'].toDate();

    if (snapshot.id[snapshot.id.length - 1] == 'P') {
      initPlayerInfo(data);
    } else {
      initTeamInfo(data);
    }
  }

  /// helper function for setting some back properties which are required
  /// to display the mini graph and scroll prices
  void setBackProperties(double currentBValue, Map dailyBValue) {
    currentBackValue = currentBValue;
    dailyBackValue = SplayTreeMap.fromIterables(
      dailyBValue.keys.map((t) => int.parse(t)),
      dailyBValue.values.map((v) => v + 0.0),
      (int t1, int t2) => t1.compareTo(t2),
    );
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
    players = List<String>.from(
        data['players'].map((playerId) => '$playerId:${data['league_id']}:${data['season_id']}}P'));
  }

  /// query the server for current X and b
  Future<void> updateCurrentX() async {
    Map<String, dynamic> holdings = await getcurrentX(id);
    if (holdings == null) {
      print('Error fetuing current holdings');
    } else {
      setCurrentX(List<double>.from(holdings['x']), holdings['b']);
    }
  }

  /// query the server for historical X and b
  Future<void> updateHistoricalX() async {
    Map<String, dynamic> histX = await getHistoricalX(id);

    if (histX == null) {
      print('Error fetching historical holdings');
    } else {
      setHistoricalX(histX['xhist'], histX['bhist']);
    }
  }

  /// given a certain current X and b, add this to the object
  void setCurrentX(List<double> holding, int b) {
    currentX = holding;
    currentB = b + 0.0;
    currentMaxX = getMax(holding);
    currentExpX = currentX.map((num i) => math.exp((i - currentMaxX) / currentB)).toList();
    currentExpXSum = getSum(currentExpX);
    n = holding.length;
    currentXLastUpdated = DateTime.now();
  }

  /// given a certain historical X and b, add this to the object
  void setHistoricalX(Map xhist, Map<String, dynamic> bhist) {
    if (id != 'cash') {
      bhist.keys.forEach((th) {
        historicalB[th] = SplayTreeMap.fromIterables(
          List<int>.from(bhist[th].keys.map((t) => int.parse(t))),
          List<double>.from(bhist[th].values.map((v) => v + 0.0)),
          (int t1, int t2) => t1.compareTo(t2),
        );
      });
    }

    xhist.keys.forEach((th) {
      historicalX[th] = SplayTreeMap.fromIterables(
        List<int>.from(xhist[th].keys.map((t) => int.parse(t))),
        List<List<double>>.from(xhist[th].values.map((qs) => List<double>.from(qs.map((qi) => qi + 0.0)))),
        (int t1, int t2) => t1.compareTo(t2),
      );

      if (id != 'cash') {
        historicalMaxX[th] = SplayTreeMap.fromIterables(
          historicalX[th].keys,
          historicalX[th].values.map((array) => getMax(List<double>.from(array))),
          (int t1, int t2) => t1.compareTo(t2),
        );
        historicalExpX[th] = SplayTreeMap.fromIterables(
            historicalX[th].keys,
            historicalX[th].keys.map((t) => historicalX[th][t]
                .map((i) => math.exp((i - historicalMaxX[th][t]) / historicalB[th][t]))
                .toList()),
            (int t1, int t2) => t1.compareTo(t2));
        historicalExpXSum[th] = SplayTreeMap.fromIterables(
          historicalX[th].keys,
          historicalX[th].keys.map((t) => getSum(historicalExpX[th][t])),
          (int t1, int t2) => t1.compareTo(t2),
        );
      }
    });
  }

  /// return the current value of a quantity q
  /// Note, current X and b must already be set
  double getCurrentValue(List<double> q) {
    if ((currentExpX == null) && (id != 'cash')) {
      print('Cannot get current value. currentExpX is not set');
      return null;
    }
    if (id == 'cash') {
      return q[0];
    } else {
      return round(dotProduct(q, currentExpX) / currentExpXSum, 6);
    }
  }

  /// return the historical value of a quantity q
  /// Note, curhistoricalrent X and b must already be set
  Map<String, SplayTreeMap<int, double>> getHistoricalValue(List<double> q) {
    if ((historicalX == null) && (id != 'cash')) {
      print('Cannot get historical value. historicalExpX is not set');
      return null;
    }
    Map<String, SplayTreeMap<int, double>> out = Map<String, SplayTreeMap<int, double>>();

    if (id == 'cash') {
      historicalX.keys.forEach((String th) {
        out[th] = SplayTreeMap.fromIterables(
          historicalX[th].keys,
          historicalX[th].keys.map((t) => q[0]),
          (int t1, int t2) => t1.compareTo(t2),
        );
      });
    } else {
      historicalExpX.keys.forEach((String th) {
        out[th] = SplayTreeMap.fromIterables(
          historicalExpX[th].keys,
          historicalExpX[th]
              .keys
              .map((t) => round(doubleDotProduct(q, historicalExpX[th][t]) / historicalExpXSum[th][t], 6)),
          (int t1, int t2) => t1.compareTo(t2),
        );
      });
    }

    return out;
  }

  /// the LMSR cost function
  double _c(List<num> x) {
    double xmax = getMax(x);
    return xmax + currentB * math.log(getSum(x.map((xi) => math.exp((xi - xmax) / currentB)).toList()));
  }

  /// price k units of a trade q
  double priceTrade(List<double> q, double k) {
    if (currentX == null) {
      print('Cannot price trade. currentX is not set');
      return null;
    }
    return _c(range(n).map((i) => currentX[i] + k * q[i]).toList()) - _c(currentX);
  }

  @override
  String toString() {
    return 'Market($id)';
  }
}
