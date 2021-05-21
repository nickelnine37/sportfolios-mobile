import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/firebase/markets.dart';
import 'markets.dart';

class Portfolio {
  String id;
  String name;
  double value;
  bool public;
  List<Market> markets;
  List<double> amounts;
  Map<String, dynamic> marketIdAmountMap;

  Portfolio(this.id);

  Portfolio.fromDocumentSnapshot(DocumentSnapshot snapshot){
    id = snapshot.id;
    Map<String, dynamic> data = snapshot.data();
    name = data['name'];
    public = data['public'];

    // markets =
    //     data['markets'].keys.map<Instrument>((String marketId) => Instrument(marketId)).toList();

    // amounts = data['markets']
    //     .keys
    //     .map<double>((String marketId) => 1.0 * data['markets'][marketId])
    //     .toList();

    // marketIdAmountMap = Map<String, dynamic>.from(data['markets']);
  }

  Future<void> populateMarkets() async {
    if (markets == null) {
      print('Cannot get markets - try adding portfolio from snapshot first');
      return;
    }
    List<Market> marketsNew = [];
    for (Market market in markets) {
      if (market.id == 'cash') {
        // marketsNew.add(Cash());
      } else {
        marketsNew.add(await getMarketById(market.id));
      }
    }
    markets = marketsNew;

    // pH = matrixMultiply(this.markets.map((market) => market.pH).toList(), this.amounts);
    // pD = matrixMultiply(this.markets.map((market) => market.pD).toList(), this.amounts);
    // pW = matrixMultiply(this.markets.map((market) => market.pW).toList(), this.amounts);
    // pM = matrixMultiply(this.markets.map((market) => market.pM).toList(), this.amounts);
    // pMax = matrixMultiply(this.markets.map((market) => market.pMax).toList(), this.amounts);

    // super.computeValueChange();
  }

  @override
  String toString() {
    return 'Portfolio(${markets.toString()})';
  }
}
