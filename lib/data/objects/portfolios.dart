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

  Map<String, Array>? transactionValue;

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
      transactionValue =  market.historicalLMSR!.getHistoricalValue(quantity).map((String th, Array valueHist) => MapEntry(
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
  late String id;
  DocumentSnapshot? doc;
  double? currentValue;
  Map<String, double> currentValues = {};
  Map<String, Asset>? holdings;
  Map<String, Market> markets = {};
  String? name;
  bool? public;
  Map<String, double>? returnHist;
  String? user;
  List<Transaction> transactions = [];
  Map<String, Array>? historicalValue;
  double? cash;
  Map<String, List<int>>? times;

  Portfolio(this.id);

  Portfolio.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    doc = snapshot;
    id = snapshot.id;
    currentValue = snapshot['current_value'];
    name = snapshot['name'];
    returnHist = {'d': snapshot['returns_d'], 'w': snapshot['returns_w'], 'm': snapshot['returns_m'], 'M': snapshot['returns_M']};
    public = snapshot['public'];
    user = snapshot['user'];
    cash = snapshot['cash'] + 0.0;

    // holdings is a map between marketId and an Asset
    holdings = Map<String, dynamic>.from(snapshot['holdings']).map((String marketName, dynamic value) {
      if (marketName.contains('T')) {
        Array quantity = Array.fromTrueDynamicList(value);
        return MapEntry(marketName, Asset.team(quantity, 1.0));
      } else {
        bool long = marketName.contains('L');
        marketName = marketName.substring(0, marketName.length - 1);
        return MapEntry(marketName, Asset.player(long, value + 0.0));
      }
    });

    transactions = snapshot['transactions'].map<Transaction>((transaction) {
      String marketName = transaction['market'];
      double price = transaction['price'] + 0.0;
      double time = transaction['time'] + 0.0;
      Market market;
      Asset quantity;

      if (marketName.contains('T')) {
        quantity = Asset.team(Array.fromTrueDynamicList(transaction['quantity']));
        if (markets.keys.contains(marketName)) {
          market = markets[marketName]!;
        } else {
          market = TeamMarket(marketName);
          markets[marketName] = market;
        }
      } else {
        quantity = Asset.player(marketName.contains('L'), transaction['quantity']);
        marketName = marketName.substring(0, marketName.length - 1);
        if (markets.keys.contains(marketName)) {
          market = markets[marketName]!;
        } else {
          market = PlayerMarket(marketName);
          markets[marketName] = market;
        }
      }

      return Transaction(market, time, price, quantity);
    }).toList();
  }

  Future<bool> checkForUpdates() async {
    DocumentSnapshot new_doc = await FirebaseFirestore.instance.collection('portfolios').doc(id).get();
    if (new_doc['transactions'].length != transactions.length) {
      print('New transactions have been added!!');
      return true;
    }
    else {
      print('No new transactions have been added');
      return false;
    }
  }

  double? getCurrentValue() {
    if (holdings != null) {
      double total = cash!;
      holdings!.forEach((String marketName, Asset asset) {
        double value = markets[marketName]!.currentLMSR!.getValue(asset);
        total += value;
        currentValues[marketName] = value;
      });
      currentValue = total;
      print('Portfolio value: ${total}');
      return total;
    }
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
    if (transactions != null) {
      await Future.wait(markets.values.map((Market market) => market.getSnapshotInfo()));
    } else {
      print('Cannot populate markets. No information has been added from firebase');
    }
  }

  Future<void> populateMarketsServer() async {
    if (transactions == null) {
      print('Cannot populate markets. No information has been added from firebase');
    } else {
      Map<String, Map<String, dynamic>>? currentHoldings = await getMultipleCurrentHoldings(markets.keys.toList());
      Map<String, Map<String, dynamic>>? historicalHoldings = await getMultipleHistoricalHoldings(markets.keys.toList());

      if ((currentHoldings != null) && (historicalHoldings != null)) {
        times = Map<String, List<int>>.from(historicalHoldings['time']!);

        for (Transaction transaction in transactions) {
          transaction.market.setCurrentHoldings(currentHoldings[transaction.market.id]!);
          transaction.market.setHistoricalHoldings(historicalHoldings['data']![transaction.market.id], times!);
        }
      } else {
        print('Unable to populateMarketsServer. Current or historical holdings failed');
      }
    }
  }
}
