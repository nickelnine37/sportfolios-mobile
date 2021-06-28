import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/requests.dart';
import '../firebase/markets.dart';
import 'markets.dart';

class Portfolio {
  // ----- basic attributes ------
  String? id;
  String? name;
  late DocumentSnapshot doc;
  bool? public;

  // ----- current market attributes -----
  // Map<String, Market> currentMarkets; // map between market id and Market object for current constituents
  double? currentValue; // latest value of whole portfolio
  Map<String, double?> currentValues = Map<String, double?>(); // latest value of individual constituents
  Map<String, List<double>> currentQuantities = Map<String, List<double>>(); // latest quantity vectors
  bool setCurrentX = false; // whether current X values have been computed
  late SplayTreeMap<String, double> sortedValues;
  int? nCurrentMarkets;
  int? nTotalMarkets;
  late List<String> currentMarketIds;

  bool setHistoricalX = false;

  late Map<String?, Market> markets;
  late List<Map<String, dynamic>> purchaseHistory;

  late DateTime lastUpdatedCurrentX;
  late DateTime lastUpdatedHistoricalX;

  // DateTime lastPushedValueServer;
  // DateTime lastPushedHistoricalValuesServer;

  Map<String, List<double>> historicalValue = Map<String, List<double>>();
  Map<String, List<int>>? times;

  Portfolio(this.id);

  Portfolio.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    id = snapshot.id;
    name = data['name'];
    public = data['public'];

    // ensure we have doubles!!!!!!
    for (String market in data['holdings'].keys) {
      currentQuantities[market] = List<double>.from(data['holdings'][market].map((i) => i + 0.0));
    }

    purchaseHistory = List<Map<String, dynamic>>.from(data['history']);

    // ensure we have doubles!!!!!!
    for (Map purchase in purchaseHistory) {
      purchase['quantity'] = List<double>.from(purchase['quantity'].map((i) => i + 0.0));
    }

    // get all markets ever used in portfolio
    markets = Map.fromIterable(data['history'].map((item) => item['market']).toSet(),
        key: (marketId) => marketId, value: (marketId) => Market(marketId));

    // get current markets in portfolio
    currentMarketIds = List<String>.from(data['holdings'].keys);

    nCurrentMarkets = data['holdings'].length;
    nTotalMarkets = markets.length;

    // lastPushedValueServer = data['lastUpdated'].toDate();
  }

  Future<void> updateQuantities() async {
    DocumentSnapshot data = await FirebaseFirestore.instance.collection('portfolios').doc(id).get();
    for (String market in data['holdings'].keys) {
      currentQuantities[market] = List<double>.from(data['holdings'][market].map((i) => i + 0.0));
    }

    purchaseHistory = List<Map<String, dynamic>>.from(data['history']);

    // ensure we have doubles!!!!!!
    for (Map purchase in purchaseHistory) {
      purchase['quantity'] = List<double>.from(purchase['quantity'].map((i) => i + 0.0));
    }

    // get current markets in portfolio
    currentMarketIds = List<String>.from(data['holdings'].keys);

    nCurrentMarkets = data['holdings'].length;
    nTotalMarkets = markets.length;

    computeCurrentValue();
  }

  Future<void> addMarketSnapshotData() async {
    Stopwatch stopwatch = new Stopwatch()..start();
    for (String? marketId in markets.keys) {
      if (marketId != 'cash') {
        DocumentSnapshot marketSnapshot = await getMarketSnapshotById(marketId!);
        markets[marketId]!.addDocumentSnapshotData(marketSnapshot);
      }
    }
    print('addMarketSnapshotData() executed in ${stopwatch.elapsed.inMilliseconds / 1000}s for ${toString()}');
  }

  Future<void> updateMarketsCurrentX() async {
    Stopwatch stopwatch = new Stopwatch()..start();
    if (!setCurrentX || (DateTime.now().difference(lastUpdatedCurrentX).inSeconds > 60)) {
      Map<String, dynamic>? currentXs = await getMultipleCurrentX(currentMarketIds);

      if (currentXs == null) {
        print('updateMarketsCurrentX() failed. getMultipleCurrentX() returned null');
        return;
      }

      for (String marketId in currentXs.keys) {
        markets[marketId]!.lmsr.setCurrentX(List<double>.from(currentXs[marketId]['x']), currentXs[marketId]['b']);
      }
      lastUpdatedCurrentX = DateTime.now();
      setCurrentX = true;
    }
    print('updateMarketsCurrentX() executed in ${stopwatch.elapsed.inMilliseconds / 1000}s for ${toString()}');
  }

  Future<void> updateMarketsHistoricalX() async {
    Stopwatch stopwatch = new Stopwatch()..start();
    if (!setHistoricalX || (DateTime.now().difference(lastUpdatedHistoricalX).inSeconds > 60)) {
      Map<String, dynamic>? historicalXs = await getMultipleHistoricalX(markets.keys.toList());

      if (historicalXs == null) {
        print('updateMarketsHistoricalX failed. getMultipleHistoricalX returned null ');
        return;
      }

      times = Map<String, List<int>>.from(historicalXs['time']);
      for (String marketId in historicalXs['data'].keys) {
        markets[marketId]!.lmsr.setHistoricalX(historicalXs['data'][marketId]['x'], historicalXs['data'][marketId]['b']);
      }
      lastUpdatedHistoricalX = DateTime.now();
      setHistoricalX = true;
    }
    print('updateMarketsHistoricalX() executed in ${stopwatch.elapsed.inMilliseconds / 1000}s for ${toString()}');
  }

  void computeCurrentValue() {
    Stopwatch stopwatch = new Stopwatch()..start();
    double total = 0;
    if (setCurrentX) {
      for (String marketId in currentQuantities.keys) {
        currentValues[marketId] = markets[marketId]!.lmsr.getValue(List<double>.from(currentQuantities[marketId]!));
        total += currentValues[marketId]!;
      }
      currentValue = total;
      // if (DateTime.now().difference(lastPushedValueServer).inSeconds > 60) {
      //   // TODO:  pushCurrentValue();
      // }
      // also compute list of current values sorted by size
      sortedValues = SplayTreeMap.from(currentValues, (String t1, String t2) => currentValues[t2]!.compareTo(currentValues[t1]!));
    } else {
      print('Cannot get portfolio value: update current X first');
    }
    print('computeCurrentValue() executed in ${stopwatch.elapsed.inMilliseconds / 1000}s for ${toString()}');
  }

  // Future<void> pushCurrentValue() async {
  //   if (currentValue != null) {
  //     print('Pushing');
  //     if (DateTime.now().difference(lastPushedValueServer).inSeconds > 120) {
  //       await FirebaseFirestore.instance
  //           .collection('portfolios')
  //           .doc(id)
  //           .update({'value': currentValue, 'lastUpdated': DateTime.now()});
  //     }
  //   }
  // }

  void computeHistoricalValue() {
    Stopwatch stopwatch = new Stopwatch()..start();

    bool firstPassComplete = false;

    print(times!['M']);

    if (setHistoricalX) {
      for (Map purchase in purchaseHistory) {
        //
        String? market = purchase['market'];
        double? purchaseTime = purchase['time'] + 0.0;
        List<double>? quantity = purchase['quantity'];
        //
        Map<String, List<double>>? historicalMarketValue = markets[market]!.lmsr.getHistoricalValue(quantity);

        if (historicalMarketValue == null) {
          continue;
        }

        for (String th in ['h', 'd', 'w', 'm', 'M']) {
          if (!firstPassComplete) {
            historicalValue[th] = List<double>.generate(60, (int i) => 0.0);
          }

          // step backwards in time, starting with the most recent
          // when we reach a time that is before our purchase, break
          for (int i = times![th]!.length - 1; i >= 0; i--) {
            if (purchaseTime! <= times![th]![i]) {
              historicalValue[th]![i] += historicalMarketValue[th]![i];
            } else {
              break;
            }
          }
        }

        firstPassComplete = true;
      }
    } else {
      print('Cannot compute historical Value: have not populated historical X');
    }
    print('computeHistoricalValue() executed in ${stopwatch.elapsed.inMilliseconds / 1000}s for ${toString()}');
  }

  @override
  String toString() {
    return 'Portfolio(${currentMarketIds.toString()})';
  }
}
