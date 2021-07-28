// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';
// import 'data/api/requests.dart';
// import 'data/utils/casting.dart';
// import 'dart:math' as math;
// import 'utils/numerical/arrays.dart';

// /// Used as the argument for any pricing-type method. Represents a holding of
// /// some asset, either a classic LMSR vector with optional scaling constant,
// /// or an amount of longs/shorts.
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
// }

// /// Base class for one-off LMSR calculations
// abstract class LMSR {
//   double getValue(Asset asset);
//   double getLongValue();
//   double priceTrade(Asset asset);
// }

// /// Team class for one-off LMSR calculations. Implements classic LMSR scheme.
// /// Initialised with Array x and double b
// class TeamLMSR extends LMSR {
//   late double b;
//   late Array x;
//   late Array qLong;

//   late double _xMax;
//   late double _expSum;
//   late Array _expX;

//   TeamLMSR({required Array this.x, required double this.b}) {
//     qLong = qLong = Array.fromList(range(x.length).map((int i) => math.exp(-i / 6)).toList());
//     _xMax = x.max;
//     _expX = x.apply((double xi) => math.exp((xi - _xMax) / b));
//     _expSum = _expX.sum;
//   }

//   @override
//   double getLongValue() {
//     return getValue(Asset.team(qLong, 10.0));
//   }

//   @override
//   double getValue(Asset asset) {
//     return asset.k == null ? asset.q!.dotProduct(_expX) / _expSum : asset.k! * (asset.q!.dotProduct(_expX) / _expSum);
//   }

//   double _c(Array x_) {
//     double xmax = x.max;
//     return xmax + b * math.log(x_.apply((double xi) => math.exp((xi - xmax) / b)).sum);
//   }

//   @override
//   double priceTrade(Asset asset) {
//     if (asset.k != null) {
//       asset.q = asset.q!.scale(asset.k!);
//     }
//     return _c(asset.q! + x) - _xMax - b * math.log(_expSum);
//   }
// }

// /// Player class for one-off LMSR calculations. Implements Long/Short LMSR scheme.
// /// Initialised with  double N and  double b
// class PlayerLMSR extends LMSR {
//   late double n;
//   late double b;

//   PlayerLMSR({required double this.n, required double this.b});

//   @override
//   double getLongValue() {
//     return getValue(Asset.player(true, 10));
//   }

//   @override
//   double getValue(Asset asset) {
//     if (asset.k == null) {
//       asset.k = 1.0;
//     }

//     if (!asset.long!) {
//       return asset.k! - getValue(Asset.player(true, asset.k));
//     }

//     double c = n / b;

//     if (c == 0) return 0.5;

//     if (c > 0)
//       return asset.k! * ((c - 1) + math.exp(-c)) / (c * (1 - math.exp(-c)));
//     else
//       return asset.k! * (math.exp(c) * (c - 1) + 1) / (c * (math.exp(c) - 1));
//   }

//   @override
//   double priceTrade(Asset asset) {
//     if (asset.k == null) {
//       asset.k = 1.0;
//     }

//     if (!asset.long!) return asset.k! + priceTrade(Asset.player(true, -asset.k!));

//     if (asset.k! == 0)
//       return 0;
//     else if (n == 0) {
//       if (asset.k! < 0)
//         return b * math.log(b * (math.exp(asset.k! / b) - 1) / asset.k!);
//       else
//         return b * math.log(b * (1 - math.exp(-asset.k! / b)) / (asset.k! * math.exp(-n / b)));
//     } else if (n < 0) {
//       if (n == -asset.k!)
//         return b * math.log(n / (b * (math.exp(n / b) - 1)));
//       else
//         return b * math.log(n / (n + asset.k!) * (math.exp((n + asset.k!) / b) - 1) / (math.exp(n / b) - 1));
//     } else {
//       if (n == -asset.k!)
//         return b * math.log(n * math.exp(-n / b) / (b * (1 - math.exp(-n / b))));
//       else
//         return b * math.log(n / (n + asset.k!) * (math.exp(asset.k! / b) - math.exp(-n / b)) / (1 - math.exp(-n / b)));
//     }
//   }
// }

// /// Base class for vector LMSR calculations. This class and derivatives
// /// are not aware of their associated time, and never exist independently of
// /// a historicalLMSR class
// abstract class MultiLMSR {
//   Array getValue(Asset asset);
// }

// /// Team class for vector LMSR calculations. Implements classic LMSR scheme.
// /// Initialised with Matrix x and Array b
// class TeamMultiLMSR extends MultiLMSR {
//   late Matrix x;
//   late Array b;

//   late Array _xMax;
//   late Array _expSum;
//   late Matrix _expX;

//   TeamMultiLMSR({required this.x, required this.b}) {
//     _xMax = x.max(1);
//     _expX = x.subtractVertical(_xMax).divideVertical(b).apply(math.exp);
//     _expSum = _expX.sum(1);
//   }

//   @override
//   Array getValue(Asset asset) {
//     return asset.k == null
//         ? _expX.multiplyHorizontal(asset.q!).sum(1) / _expSum
//         : (_expX.multiplyHorizontal(asset.q!).sum(1) / _expSum).scale(asset.k!);
//   }
// }

// /// Player class for vector LMSR calculations. Implements Long/Short LMSR scheme.
// /// Initialised with Array N and Array b
// class PlayerMultiLMSR extends MultiLMSR {
//   late Array n;
//   late Array b;
//   late Array c;

//   PlayerMultiLMSR({required this.n, required this.b}) {
//     c = n / b;
//   }

//   double longShortPrice(double cc) {
//     if (cc == 0) return 0.5;

//     if (cc > 0)
//       return ((cc - 1) + math.exp(-cc)) / (cc * (1 - math.exp(-cc)));
//     else
//       return (math.exp(cc) * (cc - 1) + 1) / (cc * (math.exp(cc) - 1));
//   }

//   @override
//   Array getValue(Asset asset) {
//     if (asset.k == null) asset.k = 1.0;

//     if (!asset.long!)
//       return Array.fill(n.length, asset.k!) - getValue(Asset.player(true, asset.k!));
//     else
//       return c.apply(longShortPrice).scale(asset.k!);
//   }
// }

// /// Base class for historical LMSR calculations. This amounts to a series
// /// of vector calculations for different time horizons. Must also come
// /// with assoicated time stamps
// abstract class HistoricalLMSR {
//   late Map<String, MultiLMSR> lmsrMap;
//   late Map<String, List<int>> ts;
//   Map<String, Array> getHistoricalValue(Asset asset);
// }

// /// Team class for historical LMSR calculations. Initialied with Map<String, Matrix>
// /// xhist, Map<String, Array> bhist and Map<String, List<int>> thist. 
// class TeamHistoricalLMSR extends HistoricalLMSR {
//   TeamHistoricalLMSR({
//     required Map<String, Matrix> xhist,
//     required Map<String, Array> bhist,
//     required Map<String, List<int>> thist,
//   }) {
//     lmsrMap = Map<String, TeamMultiLMSR>.fromIterables(
//       xhist.keys,
//       xhist.keys.map(
//         (String th) => TeamMultiLMSR(x: xhist[th]!, b: bhist[th]!),
//       ),
//     );
//     ts = thist;
//   }

//   @override
//   Map<String, Array> getHistoricalValue(Asset asset) {
//     return Map<String, Array>.fromIterables(
//       lmsrMap.keys,
//       lmsrMap.keys.map(
//         (String th) => lmsrMap[th]!.getValue(asset),
//       ),
//     );
//   }
// }

// /// Player class for histrical LMSR calculations Initialied with Map<String, Array>
// /// nhist, Map<String, Array> bhist and Map<String, List<int>> thist.
// class PlayerHisoricalLMSR extends HistoricalLMSR {
//   PlayerHisoricalLMSR({
//     required Map<String, Array> nhist,
//     required Map<String, Array> bhist,
//     required Map<String, List<int>> thist,
//   }) {
//     lmsrMap = Map<String, PlayerMultiLMSR>.fromIterables(
//         nhist.keys, nhist.keys.map((String th) => PlayerMultiLMSR(n: nhist[th]!, b: bhist[th]!)));
//     ts = thist;
//   }

//   @override
//   Map<String, Array> getHistoricalValue(Asset asset) {
//     return Map<String, Array>.fromIterables(lmsrMap.keys, lmsrMap.keys.map((String th) => lmsrMap[th]!.getValue(asset)));
//   }
// }

// abstract class Market {
//   // ----- core attributes -----
//   late String id;
//   // DocumentSnapshot? doc;

//   // ----- basic attributes -----
//   String? name;
//   List<String>? searchTerms;
//   DateTime? startDate;
//   DateTime? endDate;

//   // ----- Visual attributes -----
//   String? info1;
//   String? info2;
//   String? info3;
//   List<String>? colours;
//   String? imageURL;

//   // stats
//   Map<String, dynamic>? stats;

//   // ----- price attributes -----
//   double? longPriceCurrent;
//   Map<String, Array>? longPriceHist;
//   Map<String, double>? longPriceReturnsHist;

//   // ----- LMSR -----
//   LMSR? currentLMSR;
//   HistoricalLMSR? historicalLMSR;

//   void addSnapshotInfo(DocumentSnapshot snapshot) {
//     id = snapshot.id;
//     name = snapshot['name'];

//     if (snapshot['colours'] == null) {
//       colours = ['#1544B8', '#1544B8', '#183690', '#183690', '#183690', '#183690', '#1544B8'];
//     } else {
//       colours = List<String>.from(snapshot['colours']);
//     }

//     searchTerms = List<String>.from(snapshot['search_terms']);
//     imageURL = snapshot['image'];
//     startDate = snapshot['start_date'].toDate();
//     endDate = snapshot['end_date'].toDate();

//     // longPriceCurrent = data['long_price_current'];
//     longPriceHist = castHistArray(snapshot['long_price_hist']);
//     longPriceReturnsHist = <String, double>{
//       'd': snapshot['long_price_returns_d'],
//       'w': snapshot['long_price_returns_w'],
//       'm': snapshot['long_price_returns_m'],
//       'M': snapshot['long_price_returns_M']
//     };
//   }

//   Future<void> getSnapshotInfo();

//   Future<void> getCurrentHoldings();

//   void setCurrentHoldings(Map<String, dynamic> currentHoldings);

//   Future<void> getHistoricalHoldings();

//   void setHistoricalHoldings(Map<String, dynamic> data, Map<String, List<int>> time);
// }

// class PlayerMarket extends Market {
//   String? team_id;

//   PlayerMarket(String idd) {
//     id = idd;
//   }

//   PlayerMarket.fromDocumentSnapshot(DocumentSnapshot snapshot) {
//     addSnapshotInfo(snapshot);
//   }

//   @override
//   void addSnapshotInfo(DocumentSnapshot snapshot) {
//     super.addSnapshotInfo(snapshot);
//     if (snapshot['name'].length > 20) {
//       List names = snapshot['name'].split(" ");
//       if (names.length > 2)
//         name = names.first + ' ' + names.last;
//       else
//         name = names.last;
//     } else
//       name = snapshot['name'];

//     info1 = snapshot['country_flag'] + ' ' + snapshot['position'];
//     info2 = "Hey";

//     if (snapshot['team_name'].length > 20)
//       info3 = snapshot['team_name'].split(" ")[0];
//     else
//       info3 = snapshot['team_name'];

//     team_id = '${snapshot['team_id']}:${snapshot['league_id']}:${snapshot['season_id']}T';
//   }

//   Future<void> getSnapshotInfo() async {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('players').doc(id).get();
//     addSnapshotInfo(snapshot);
//   }

//   @override
//   Future<void> getCurrentHoldings() async {
//     Map<String, dynamic>? currentHoldings = await getCurrentHoldingsFromServer(id);
//     if (currentHoldings != null) {
//       currentLMSR = PlayerLMSR(n: currentHoldings['N'], b: currentHoldings['b']);
//       longPriceCurrent = currentLMSR!.getLongValue();
//     } else {
//       print('Error: getCurrentHoldings(${id}) returned null');
//     }
//   }

//   @override
//   void setCurrentHoldings(Map<String, dynamic> currentHoldings) {
//     currentLMSR = PlayerLMSR(n: currentHoldings['N'], b: currentHoldings['b']);
//     longPriceCurrent = currentLMSR!.getLongValue();
//   }

//   @override
//   Future<void> getHistoricalHoldings() async {
//     Map<String, dynamic>? historicalHoldings = await getHistoricalHoldingsFromServer(id);
//     if (historicalHoldings != null) {
//       historicalLMSR = PlayerHisoricalLMSR(
//           nhist: historicalHoldings['data']['N'], bhist: historicalHoldings['data']['b'], thist: historicalHoldings['time']);
//     } else {
//       print('Error: getCurrentHoldings(${id}) returned null');
//     }
//   }

//   @override
//   void setHistoricalHoldings(Map<String, dynamic> data, Map<String, List<int>> time) {
//     historicalLMSR = PlayerHisoricalLMSR(nhist: data['N'], bhist: data['b'], thist: time);
//   }

//   @override
//   String toString() {
//     return 'PlayerMarket(${id})';
//   }
// }

// class TeamMarket extends Market {
//   List<String>? players;

//   TeamMarket(String idd) {
//     id = idd;
//   }

//   TeamMarket.fromDocumentSnapshot(DocumentSnapshot snapshot) {
//     addSnapshotInfo(snapshot);
//   }

//   @override
//   void addSnapshotInfo(DocumentSnapshot snapshot) {
//     super.addSnapshotInfo(snapshot);
//     name = snapshot['name'];
//     info1 = "P ${snapshot['played']}";
//     info2 = "GD ${snapshot['goal_difference'] > 0 ? '+' : '-'}${snapshot['goal_difference'].abs()}";
//     info3 = "PTS ${snapshot['points']}";
//     players = List<String>.from(snapshot['players'].map((playerId) => '$playerId:${snapshot['league_id']}:${snapshot['season_id']}}P'));
//   }

//   Future<void> getSnapshotInfo() async {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('teams').doc(id).get();
//     addSnapshotInfo(snapshot);
//   }

//   @override
//   String toString() {
//     return 'TeamMarket(${id})';
//   }

//   @override
//   Future<void> getCurrentHoldings() async {
//     Map<String, dynamic>? currentHoldings = await getCurrentHoldingsFromServer(id);
//     if (currentHoldings != null) {
//       currentLMSR = TeamLMSR(x: currentHoldings['x'], b: currentHoldings['b']);
//       longPriceCurrent = currentLMSR!.getLongValue();
//     } else {
//       print('Error: getCurrentHoldings(${id}) returned null');
//     }
//   }

//   @override
//   void setCurrentHoldings(Map<String, dynamic> currentHoldings) {
//     currentLMSR = TeamLMSR(x: currentHoldings['x'], b: currentHoldings['b']);
//     longPriceCurrent = currentLMSR!.getLongValue();
//   }

//   @override
//   Future<void> getHistoricalHoldings() async {
//     Map<String, dynamic>? historicalHoldings = await getHistoricalHoldingsFromServer(id);
//     if (historicalHoldings != null) {
//       historicalLMSR = TeamHistoricalLMSR(
//           xhist: historicalHoldings['data']['x'], bhist: historicalHoldings['data']['b'], thist: historicalHoldings['time']);
//     } else {
//       print('Error: getCurrentHoldings(${id}) returned null');
//     }
//   }

//   @override
//   void setHistoricalHoldings(Map<String, dynamic> data, Map<String, List<int>> time) {
//     historicalLMSR = TeamHistoricalLMSR(xhist: data['x'], bhist: data['b'], thist: time);
//   }
// }

// class Transaction {
//   late Market market;
//   late double time;
//   late double price;
//   late Asset quantity;

//   Transaction(this.market, this.time, this.price, this.quantity);

//   double? getCurrentValue() {
//     if (market.currentLMSR == null)
//       print('Cannot get current value for transaction as current lmsr for ${market} has not been set');
//     else
//       return market.currentLMSR!.getValue(quantity) - price;
//   }

//   Map<String, Array>? getHistoricalValue() {
//     if (market.historicalLMSR == null)
//       print('Cannt get historical value for transaction as historical lmsr for ${market} has not been set');
//     else
//       return market.historicalLMSR!.getHistoricalValue(quantity).map((String th, Array valueHist) => MapEntry(
//           th,
//           Array.fromDynamicList(range(valueHist.length).map((int i) {
//             if (market.historicalLMSR!.ts[th]![i] < time) {
//               return 0.0;
//             } else {
//               return valueHist[i] - price;
//             }
//           }).toList())));
//   }

//   @override
//   String toString() {
//     return 'Transaction(${market}, t=${time.toStringAsFixed(0)}), £${price.toStringAsFixed(2)}';
//   }
// }

// class Portfolio {
//   late String id;
//   double? currentValue;
//   Map<String, dynamic>? holdings;
//   List<String>? markets;
//   String? name;
//   bool? public;
//   Map<String, double>? returnHist;
//   String? user;
//   List<Transaction>? transactions;

//   Portfolio(this.id);

//   Portfolio.fromDocumentSnapshpot(DocumentSnapshot doc) {
//     id = doc.id;
//     currentValue = doc['current_value'];
//     // markets = List<String>.from(doc['markets']);
//     name = doc['name'];
//     returnHist = {'d': doc['returns_d'], 'w': doc['returns_w'], 'm': doc['returns_m'], 'M': doc['returns_M']};
//     public = doc['public'];
//     user = doc['user'];

//     transactions = doc['transactions'].map<Transaction>((transaction) {
//       String marketName = transaction['market'];
//       double price = transaction['price'];
//       double time = transaction['time'];
//       Market market;
//       Asset quantity;

//       if (marketName.contains('T')) {
//         quantity = Asset.team(Array.fromDynamicList(transaction['quantity']));
//         market = TeamMarket(marketName);
//       } else {
//         quantity = Asset.player(marketName.contains('L'), transaction['quantity']);
//         market = PlayerMarket(marketName.substring(0, marketName.length - 1));
//       }

//       return Transaction(market, time, price, quantity);
//     }).toList();

//     markets = transactions!.map((Transaction transaction) => transaction.market.id).toList();
//   }

//   double? getCurrentValue() {
//     if (transactions != null) {
//       double total = 500.0;
//       for (Transaction transaction in transactions!) {
//         total += transaction.getCurrentValue() ?? 0;
//       }
//       return total;
//     }
//   }

//   Map<String, Array> getHistoricalValue() {
//     Stopwatch stopwatch = new Stopwatch()..start();

//     Map<String, Array> historicalValue = {
//       'h': Array.fill(transactions![0].market.historicalLMSR!.ts['h']!.length, 500.0),
//       'd': Array.fill(transactions![0].market.historicalLMSR!.ts['d']!.length, 500.0),
//       'w': Array.fill(transactions![0].market.historicalLMSR!.ts['w']!.length, 500.0),
//       'm': Array.fill(transactions![0].market.historicalLMSR!.ts['m']!.length, 500.0),
//       'M': Array.fill(transactions![0].market.historicalLMSR!.ts['M']!.length, 500.0)
//     };

//     for (Transaction transaction in transactions!) {
//       Map<String, Array> transactionValue = transaction.getHistoricalValue()!;
//       for (String th in ['h', 'd', 'w', 'm', 'M']) {
//         historicalValue[th] = historicalValue[th]! + transactionValue[th]!;
//       }
//     }
//     print('computeHistoricalValue() executed in ${stopwatch.elapsed.inMilliseconds / 1000}s for ${toString()}');

//     return historicalValue;
//   }

//   Future<void> populateMarketsFirebase() async {
//     if (transactions != null) {
//       await Future.wait(transactions!.map((Transaction transaction) => transaction.market.getSnapshotInfo()));
//     } else {
//       print('Cannot populate markets. No information has been added from firebase');
//     }
//   }

//   Future<void> populateMarketsServer() async {
//     if (transactions == null) {
//       print('Cannot populate markets. No information has been added from firebase');
//     } else {
//       Map<String, Map<String, dynamic>>? currentHoldings = await getMultipleCurrentHoldings(markets!);
//       Map<String, Map<String, dynamic>>? historicalHoldings = await getMultipleHistoricalHoldings(markets!);

//       if ((currentHoldings != null) && (historicalHoldings != null)) {
//         Map<String, List<int>> times = Map<String, List<int>>.from(historicalHoldings['time']!);

//         for (Transaction transaction in transactions!) {
//           transaction.market.setCurrentHoldings(currentHoldings[transaction.market.id]!);
//           transaction.market.setHistoricalHoldings(historicalHoldings['data']![transaction.market.id], times);
//         }
//       } else {
//         print('Unable to populateMarketsServer. Current or historical holdings failed');
//       }
//     }
//   }
// }
