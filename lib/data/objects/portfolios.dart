
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/api/requests.dart';
import '../../data/lmsr/lmsr.dart';
import '../../utils/numerical/array_operations.dart';
import '../../utils/numerical/arrays.dart';
import 'markets.dart';

class Transaction {
  late Market market;
  late double time;
  late double price;
  late Asset quantity;

  Transaction(this.market, this.time, this.price, this.quantity);

  double? getCurrentValue() {
    if (market.currentLMSR == null)
      print('Cannot get current value for transaction as current lmsr for ${market} has not been set');
    else
      return market.currentLMSR!.getValue(quantity) - price;
  }

  Map<String, Array>? getHistoricalValue() {
    if (market.historicalLMSR == null)
      print('Cannt get historical value for transaction as historical lmsr for ${market} has not been set');
    else
      return market.historicalLMSR!.getHistoricalValue(quantity).map((String th, Array valueHist) => MapEntry(
          th,
          Array.fromDynamicList(range(valueHist.length).map((int i) {
            if (market.historicalLMSR!.ts[th]![i] < time) {
              return 0.0;
            } else {
              return valueHist[i] - price;
            }
          }).toList())));
  }

  @override
  String toString() {
    return 'Transaction(${market}, t=${time.toStringAsFixed(0)}), £${price.toStringAsFixed(2)}';
  }
}

class Portfolio {

  late String id;
  DocumentSnapshot? doc;
  double? currentValue;
  Map<String, double> currentValues = {};
  Map<String, dynamic>? holdings;
  List<String>? markets;
  String? name;
  bool? public;
  Map<String, double>? returnHist;
  String? user;
  List<Transaction>? transactions;
  Map<String, Array>? historicalValue;

  Portfolio(this.id);

  Portfolio.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    doc = snapshot;
    id = snapshot.id;
    currentValue = snapshot['current_value'];
    // markets = List<String>.from(doc['markets']);
    name = snapshot['name'];
    returnHist = {'d': snapshot['returns_d'], 'w': snapshot['returns_w'], 'm': snapshot['returns_m'], 'M': snapshot['returns_M']};
    public = snapshot['public'];
    user = snapshot['user'];

    transactions = snapshot['transactions'].map<Transaction>((transaction) {
      String marketName = transaction['market'];
      double price = transaction['price'];
      double time = transaction['time'];
      Market market;
      Asset quantity;

      if (marketName.contains('T')) {
        quantity = Asset.team(Array.fromDynamicList(transaction['quantity']));
        market = TeamMarket(marketName);
      } else {
        quantity = Asset.player(marketName.contains('L'), transaction['quantity']);
        market = PlayerMarket(marketName.substring(0, marketName.length - 1));
      }

      return Transaction(market, time, price, quantity);
    }).toList();

    markets = transactions!.map((Transaction transaction) => transaction.market.id).toList();
  }

  double? getCurrentValue() {
    if (transactions != null) {
      double total = 500.0;
      for (Transaction transaction in transactions!) {
        double value = transaction.getCurrentValue() ?? 0;
        currentValues[transaction.market.id] = value;
        total += value;
      }
      currentValue = total;
      return total;
    }
  }

  Map<String, Array> getHistoricalValue() {
    Stopwatch stopwatch = new Stopwatch()..start();

    historicalValue = {
      'h': Array.fill(transactions![0].market.historicalLMSR!.ts['h']!.length, 500.0),
      'd': Array.fill(transactions![0].market.historicalLMSR!.ts['d']!.length, 500.0),
      'w': Array.fill(transactions![0].market.historicalLMSR!.ts['w']!.length, 500.0),
      'm': Array.fill(transactions![0].market.historicalLMSR!.ts['m']!.length, 500.0),
      'M': Array.fill(transactions![0].market.historicalLMSR!.ts['M']!.length, 500.0)
    };

    for (Transaction transaction in transactions!) {
      Map<String, Array> transactionValue = transaction.getHistoricalValue()!;
      for (String th in ['h', 'd', 'w', 'm', 'M']) {
        historicalValue![th] = historicalValue![th]! + transactionValue[th]!;
      }
    }
    print('computeHistoricalValue() executed in ${stopwatch.elapsed.inMilliseconds / 1000}s for ${toString()}');

    return historicalValue!;
  }

  Future<void> populateMarketsFirebase() async {
    if (transactions != null) {
      await Future.wait(transactions!.map((Transaction transaction) => transaction.market.getSnapshotInfo()));
    } else {
      print('Cannot populate markets. No information has been added from firebase');
    }
  }

  Future<void> populateMarketsServer() async {
    if (transactions == null) {
      print('Cannot populate markets. No information has been added from firebase');
    } else {
      Map<String, Map<String, dynamic>>? currentHoldings = await getMultipleCurrentHoldings(markets!);
      Map<String, Map<String, dynamic>>? historicalHoldings = await getMultipleHistoricalHoldings(markets!);

      if ((currentHoldings != null) && (historicalHoldings != null)) {
        Map<String, List<int>> times = Map<String, List<int>>.from(historicalHoldings['time']!);

        for (Transaction transaction in transactions!) {
          transaction.market.setCurrentHoldings(currentHoldings[transaction.market.id]!);
          transaction.market.setHistoricalHoldings(historicalHoldings['data']![transaction.market.id], times);
        }
      } else {
        print('Unable to populateMarketsServer. Current or historical holdings failed');
      }
    }
  }
}
