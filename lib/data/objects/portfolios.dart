import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/design/colors.dart';
import 'package:sportfolios_alpha/utils/strings/number_format.dart';
import '../../data/api/requests.dart';
import '../../utils/numerical/array_operations.dart';
import '../../utils/numerical/arrays.dart';
import 'markets.dart';

/// function to determine what kind of contract is associated with a given q vector
String classify(Array quantity) {
  if (quantity.length == 2) {
    if (quantity[0] == 0) {
      return 'short';
    } else if (quantity[1] == 0) {
      return 'long';
    }
    return 'long/short';
  }

  for (int i = 0; i < quantity.length - 1; i++) {
    if (((quantity[i] / quantity[i + 1]) - 1.1813).abs() > 0.001) {
      break;
    }
    if (i == quantity.length - 2) {
      return 'short';
    }
  }

  for (int i = 0; i < quantity.length - 1; i++) {
    if (((quantity[i] / quantity[i + 1]) - 0.8464).abs() > 0.001) {
      break;
    }
    if (i == quantity.length - 2) {
      return 'long';
    }
  }

  int diffs = 0;

  for (int i = 0; i < quantity.length - 1; i++) {
    if ((quantity[i] - quantity[i + 1]).abs() > 0.001) {
      diffs += 1;
    }
  }

  if (diffs == 1) {
    return 'binary';
  }

  return 'custom';
}

class Transaction {
  late Market market;
  late double time;
  late double price;
  late Array quantity;
  late String contractType;

  Map<String, Array>? transactionValue;

  Transaction(this.market, this.time, this.price, this.quantity) {
    contractType = classify(quantity);
  }

  double? getCurrentValue({bool takePrice = true}) {
    if (market.currentLMSR == null)
      print('Cannot get current value for transaction as current lmsr for ${market} has not been set');
    else if (takePrice) {
      return market.currentLMSR!.getValue(quantity) - price;
    } else {
      return market.currentLMSR!.getValue(quantity);
    }
  }

  Map<String, Array>? getHistoricalValue({bool takePrice = true}) {
    if (market.historicalLMSR == null)
      print('Cannt get historical value for transaction as historical lmsr for ${market} has not been set');
    else
      transactionValue = market.historicalLMSR!.getHistoricalValue(quantity).map((String th, Array valueHist) => MapEntry(
          th,
          Array.fromDynamicList(range(valueHist.length).map((int i) {
            if (market.historicalLMSR!.ts[th]![i] < time) {
              return 0.0;
            } else {
              return valueHist[i] - price;
            }
          }).toList())));
    return transactionValue;
  }

  @override
  String toString() {
    return 'Transaction(${market}, t=${time.toStringAsFixed(0)}), £${price.toStringAsFixed(2)}';
  }
}

class Portfolio {
  //
  // ----- core attributes -----
  late String id;
  late String name;
  late bool public;
  late String user;
  late String username;
  late String description;
  late DocumentSnapshot doc; //                     doc object used for ordering queries
  Map<String, Market> markets = {}; //              holds all the unique markets ever used in this portfolio
  late Map<String, Color> colours;
  late Map<String, Map<String, dynamic>> comments;

  // ----- current value attributes -----
  late double cash; //                              current amount of cash in portfolio
  late double currentValue; //                      total value of portfolio. Initial estimate from firebase, updated when server call made
  late Map<String, double> currentValues; //        map market to value. Initial estimate from firebase, updated when server call made
  late Map<String, Array> holdings; //              current holdigs, from firebase

  // ------- historical value attributes --------
  late List<Transaction> transactions; //           list of Transaction objects
  late Map<String, double> periodReturns; //        map time-horizon to period returns
  Map<String, Array>? historicalValue; //           map from time horizon to value array
  Map<String, List<int>>? times; //                 corresponding map to array of timestamps

  // ---- what's been run? -------
  bool firebaseMarketsRun = false;
  bool serverCurrentValuesRun = false;
  bool serverHistoricValuesRun = false;

  Portfolio.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    doc = snapshot;
    id = snapshot.id;
    currentValue = snapshot['current_value'];
    name = snapshot['name'];
    username = snapshot['username'];
    periodReturns = {'d': snapshot['returns_d'], 'w': snapshot['returns_w'], 'm': snapshot['returns_m'], 'M': snapshot['returns_M']};
    public = snapshot['public'];
    user = snapshot['user'];
    cash = snapshot['cash'] + 0.0;
    description = snapshot['description'];
    comments = Map<String, Map<String, dynamic>>.from(snapshot['comments']);

    currentValues = Map<String, double>.from(snapshot['current_values']);
    colours = Map<String, String>.from(snapshot['colours']!).map((key, value) => MapEntry(key, fromHex(value)));

    // holdings is a map between marketId and an Asset
    holdings = Map<String, List>.from(snapshot['holdings']).map(
      (String marketName, List quantity) => MapEntry(
        marketName,
        Array.fromTrueDynamicList(quantity),
      ),
    );

    transactions = snapshot['transactions'].map<Transaction>((transaction) {
      String marketName = transaction['market'];
      double price = transaction['price'] + 0.0;
      double time = transaction['time'] + 0.0;
      Array quantity = Array.fromTrueDynamicList(transaction['quantity']);
      Market market;

      if (markets.keys.contains(marketName)) {
        market = markets[marketName]!;
      } else {
        market = marketName.contains('T') ? TeamMarket(marketName) : PlayerMarket(marketName);
        markets[marketName] = market;
      }

      return Transaction(market, time, price, quantity);
    }).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    cash -= transaction.price;

    // this market is already in the portfolio
    // we're either buying more, or selling
    if (holdings.keys.contains(transaction.market.id)) {
      holdings[transaction.market.id] = holdings[transaction.market.id]! + transaction.quantity;
      currentValues[transaction.market.id] = currentValues[transaction.market.id]! + transaction.price;
      if (currentValues[transaction.market.id]! < 0.02) {
        currentValues.remove(transaction.market.id);
        holdings.remove(transaction.market.id);
      }
    }
    // this is a totally new market
    else {
      holdings[transaction.market.id] = transaction.quantity;
      markets[transaction.market.id] = transaction.market;
      colours[transaction.market.id] = fromHex(transaction.market.colours![0]);
      currentValues[transaction.market.id] = transaction.price;
      await transaction.market.getCurrentHoldings();
      await transaction.market.getHistoricalHoldings();
    }
      transaction.getCurrentValue();
      transaction.getHistoricalValue();
    transactions.add(transaction);
  }

  Map<String, Array> aggregateTransactions(String marketId) {
    Map<String, Array> out = transactions[0].transactionValue!.map((key, value) => MapEntry(key, Array.zeros(value.length)));

    if (!holdings.containsKey(marketId)) {
      return out;
    }

    for (Transaction transaction in transactions) {
      if (transaction.market.id == marketId) {
        if (transaction.transactionValue != null) {
          for (String th in ['h', 'd', 'w', 'm', 'M']) {
            out[th] = out[th]! + transaction.transactionValue![th]!;
          }
        }
      }
    }

    return out;
  }

  Future<bool> checkForUpdates() async {
    DocumentSnapshot new_doc = await FirebaseFirestore.instance.collection('portfolios').doc(id).get();
    if (new_doc['transactions'].length != transactions.length) {
      print('New transactions have been added!!');
      return true;
    } else {
      print('No new transactions have been added');
      return false;
    }
  }

  double? getCurrentValue() {
    if (!serverCurrentValuesRun) {
      return null;
    }

    double total = cash;
    holdings.forEach((String marketName, Array quantity) {
      double value = markets[marketName]!.currentLMSR!.getValue(quantity);
      total += value;
      currentValues[marketName] = value;
    });
    currentValue = total;
    return total;
  }

  Map<String, Array> getHistoricalValue() {
    Stopwatch stopwatch = new Stopwatch()..start();

    historicalValue = {
      'h': Array.fill(times!['h']!.length, 500.0),
      'd': Array.fill(times!['d']!.length, 500.0),
      'w': Array.fill(times!['w']!.length, 500.0),
      'm': Array.fill(times!['m']!.length, 500.0),
      'M': Array.fill(times!['M']!.length, 500.0)
    };

    for (Transaction transaction in transactions) {
      Map<String, Array> transactionValue = transaction.getHistoricalValue()!;
      for (String th in ['h', 'd', 'w', 'm', 'M']) {
        historicalValue![th] = historicalValue![th]! + transactionValue[th]!;
      }
    }
    print('computeHistoricalValue() executed in ${stopwatch.elapsed.inMilliseconds / 1000}s for ${toString()}');

    return historicalValue!;
  }

  Future<void> populateMarketsFirebase() async {
    await Future.wait(markets.values.map((Market market) => market.getSnapshotInfo()));
    firebaseMarketsRun = true;
  }

  Future<void> populateMarketsServer() async {
    Map<String, Map<String, dynamic>>? currentHoldings = await getMultipleCurrentHoldings(markets.keys.toList());
    Map<String, Map<String, dynamic>>? historicalHoldings = await getMultipleHistoricalHoldings(markets.keys.toList());

    if (historicalHoldings != null) {
      serverHistoricValuesRun = true;
      times = Map<String, List<int>>.from(historicalHoldings['time']!);
    }

    if ((currentHoldings != null) && (historicalHoldings != null)) {
      serverCurrentValuesRun = true;
      for (Market market in markets.values) {
        market.setCurrentHoldings(currentHoldings[market.id]!);
        market.setHistoricalHoldings(historicalHoldings['data']![market.id], times!);
      }
    } else {
      print('Unable to populateMarketsServer. Current or historical holdings failed');
    }
  }

  @override
  String toString() {
    return 'Portfolio(${name}; ${formatCurrency(currentValue, 'GBP')})';
  }
}
