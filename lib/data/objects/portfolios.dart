import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/data/firebase/markets.dart';
import 'markets.dart';

class Portfolio {
  // ----- basic attributes ------
  String id;
  String name;
  DocumentSnapshot doc;
  bool public;

  // ----- current market attributes -----
  Map<String, Market> currentMarkets; // map between market id and Market object for current constituents
  double currentValue; // latest value of whole portfolio
  Map<String, double> currentValues = Map<String, double>(); // latest value of individual constituents
  Map<String, List<double>> currentQuantities =
      Map<String, List<double>>(); // latest quantity vectors of individual constituents
  bool setCurrentX = false; // whether current X values have been computed
  LinkedHashMap<String, double> sortedValues;
  int nCurrentMarkets;
  int nTotalMarkets;

  bool setHistoricalX = false;

  Map<String, Market> allMarkets;
  List<Map<String, dynamic>> purchaseHistory;

  DateTime lastUpdatedCurrentX;
  DateTime lastUpdatedHistoricalX;

  DateTime lastPushedValueServer;
  DateTime lastPushedHistoricalValuesServer;

  Map<String, LinkedHashMap<int, double>> historicalValue = Map<String, LinkedHashMap<int, double>>();

  Portfolio(this.id);

  Portfolio.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();

    id = snapshot.id;
    name = data['name'];
    public = data['public'];

    // ensure we have doubles!!!!!!
    for (String market in data['current'].keys) {
      currentQuantities[market] = List<double>.from(data['current'][market].map((i) => i + 0.0));
    }

    purchaseHistory = List<Map<String, dynamic>>.from(data['history']);

    // ensure we have doubles!!!!!!
    for (Map purchase in purchaseHistory) {
      purchase['quantity'] = List<double>.from(purchase['quantity'].map((i) => i + 0.0));
    }

    // get all markets ever used in portfolio
    allMarkets = Map.fromIterable(data['history'].map((item) => item['market']).toSet(),
        key: (marketId) => marketId, value: (marketId) => Market(marketId));

    // get current markets in portfolio
    currentMarkets = Map.fromIterable(data['current'].keys,
        key: (marketId) => marketId, value: (marketId) => Market(marketId));
    
    nCurrentMarkets = currentMarkets.length;
    nTotalMarkets = allMarkets.length;
    
    lastPushedValueServer = data['lastUpdated'].toDate();
  }

  Future<void> addMarketSnapshotData() async {
    for (String marketId in allMarkets.keys) {
      if (marketId != 'cash') {
        DocumentSnapshot marketSnapshot = await getMarketSnapshotById(marketId);
        allMarkets[marketId].addDocumentSnapshotData(marketSnapshot);
        currentMarkets[marketId].addDocumentSnapshotData(marketSnapshot);
      }
    }
  }

  Future<void> updateMarketsCurrentX() async {
    if (!setCurrentX || (DateTime.now().difference(lastUpdatedCurrentX).inSeconds > 60)) {
      Map<String, dynamic> currentXs = await getMultipleCurrentX(currentMarkets.keys.toList());
      for (String marketId in currentXs.keys) {
        currentMarkets[marketId]
            .setCurrentX(List<double>.from(currentXs[marketId]['x']), currentXs[marketId]['b']);
      }
      lastUpdatedCurrentX = DateTime.now();
      setCurrentX = true;
    }
  }

  Future<void> updateMarketsHistoricalX() async {
    if (!setHistoricalX || (DateTime.now().difference(lastUpdatedHistoricalX).inSeconds > 60)) {
      Map<String, dynamic> historicalXs = await getMultipleHistoricalX(allMarkets.keys.toList());
      for (String marketId in historicalXs.keys) {
        allMarkets[marketId].setHistoricalX(historicalXs[marketId]['xhist'], historicalXs[marketId]['bhist']);
      }
      lastUpdatedHistoricalX = DateTime.now();
      setHistoricalX = true;
    }
  }

  void computeCurrentValue() {
    double total = 0;
    if (setCurrentX) {
      for (String marketId in currentQuantities.keys) {
        currentValues[marketId] =
            currentMarkets[marketId].getCurrentValue(List<double>.from(currentQuantities[marketId]));
        total += currentValues[marketId];
      }
      currentValue = total;
      if (DateTime.now().difference(lastPushedValueServer).inSeconds > 60) {
        // TODO:  pushCurrentValue();
      }
      // also compute list of current values sorted by size
      sortedValues = LinkedHashMap.fromIterable(
          currentValues.keys.toList(growable: false)
            ..sort((k1, k2) => currentValues[k2].compareTo(currentValues[k1])),
          key: (k) => k,
          value: (k) => currentValues[k]);
    } else {
      print('Cannot get portfolio value: update current X first');
    }
  }

  Future<void> pushCurrentValue() async {
    if (currentValue != null) {
      print('Pushing');
      if (DateTime.now().difference(lastPushedValueServer).inSeconds > 120) {
        await FirebaseFirestore.instance
            .collection('portfolios')
            .doc(id)
            .update({'value': currentValue, 'lastUpdated': DateTime.now()});
      }
    }
  }

  void computeHistoricalValue() {
    bool firstPassComplete = false;

    if (setHistoricalX) {
      for (Map purchase in purchaseHistory) {
        //
        String market = purchase['market'];
        double purchaseTime = purchase['time'] + 0.0;
        List<double> quantity = purchase['quantity'];
        //
        Map<String, LinkedHashMap<int, double>> historicalMarketValue =
            allMarkets[market].getHistoricalValue(quantity);

        for (String ts in ['h', 'd', 'w', 'm', 'M']) {
          if (!firstPassComplete) {
            historicalValue[ts] = LinkedHashMap<int, double>();
          }
          for (int t in historicalMarketValue[ts].keys) {
            if (!firstPassComplete) {
              historicalValue[ts][t] = 0.0;
            }
            if (purchaseTime <= t) {
              historicalValue[ts][t] += historicalMarketValue[ts][t];
            }
          }
        }
        firstPassComplete = true;
      }
    } else {
      print('Cannot compute historical Value: have not populated historical X');
    }
  }

  @override
  String toString() {
    return 'Portfolio(${currentMarkets.toString()})';
  }
}
