import 'dart:collection';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/data/firebase/contracts.dart';
import 'package:sportfolios_alpha/data/models/base.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/numbers.dart';

class Instrument extends BaseDataModel {
  String name;
  double value;

  List<double> pH;
  List<double> pD;
  List<double> pW;
  List<double> pM;
  List<double> pMax;

  double hourReturn;
  double dayReturn;
  double weekReturn;
  double monthReturn;
  double totalReturn;

  double hourValueChange;
  double dayValueChange;
  double weekValueChange;
  double monthValueChange;
  double totalValueChange;

  Instrument(String id) : super(id);

  computeValueChange() {
    value = pH.last;

    hourValueChange = (value - pH.first);
    dayValueChange = (value - pD.first);
    weekValueChange = (value - pW.first);
    monthValueChange = (value - pM.first);
    totalValueChange = (value - pMax.first);

    hourReturn = hourValueChange / pH.first;
    dayReturn = dayValueChange / pD.first;
    weekReturn = weekValueChange / pW.first;
    monthReturn = monthValueChange / pM.first;
    totalReturn = totalValueChange / pMax.first;
  }

  @override
  String toString() {
    return 'Instrument($id)';
  }
}

class Cash extends Instrument {
  Cash() : super('cash') {
    name = 'Cash';
    pH = ones(120);
    pD = ones(120);
    pW = ones(120);
    pM = ones(120);
    pMax = ones(120);

    super.computeValueChange();
  }

  @override
  String toString() {
    return 'Cash()';
  }
}

class Contract extends Instrument {
  String teamOrPlayer;
  String longOrShort;
  List<String> searchTerms;
  String imageURL;
  String team;
  double currentBackValue;
  LinkedHashMap<int, double> dailyBackValue;
  DateTime currentValueLastUpdated;

  // info to to be shown on left of summary tile
  String info1;
  String info2;
  String info3;

  List<String> colours;
  DocumentSnapshot doc;

  int n;

  List<double> currentHolding;
  List<double> currentHoldingExp;
  double currentHoldingMax;
  double currentHoldingExpSum;
  double currentB;

  Map<String, LinkedHashMap<int, List>> historicalHoldings = Map<String, LinkedHashMap<int, List>>();
  Map<String, LinkedHashMap<int, List>> historicalHoldingsExp = Map<String, LinkedHashMap<int, List>>();
  Map<String, LinkedHashMap<int, double>> historicalHoldingMax = Map<String, LinkedHashMap<int, double>>();
  Map<String, LinkedHashMap<int, double>> historicalHoldingExpSum = Map<String, LinkedHashMap<int, double>>();
  Map<String, LinkedHashMap<int, double>> historicalB = Map<String, LinkedHashMap<int, double>>();

  Contract(String contractId) : super(contractId);

  LinkedHashMap<int, double> sortPriceTimeMap(Map values) {
    List times = values.keys.toList(growable: false);
    LinkedHashMap<int, double> out = LinkedHashMap<int, double>();
    times.sort();
    times.forEach((k1) {
      out[int.parse(k1)] = 0.0 + values[k1];
    });
    return out;
  }

  LinkedHashMap<int, List> sortHoldingsTimeMap(Map values) {
    List times = values.keys.toList(growable: false);
    LinkedHashMap<int, List> out = LinkedHashMap<int, List>();
    times.sort();
    times.forEach((k1) {
      out[int.parse(k1)] = values[k1];
    });
    return out;
  }

  Contract.fromDocumentSnapshotAndPrices(DocumentSnapshot snapshot, double currentValue, Map dailyValue)
      : super(snapshot.id) {
    Map<String, dynamic> data = snapshot.data();
    doc = snapshot;

    currentBackValue = currentValue;
    dailyBackValue = sortPriceTimeMap(dailyValue);
    colours = List<String>.from(data['colours']);

    if (snapshot.id[snapshot.id.length - 1] == 'P') {
      teamOrPlayer = 'player';

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
      teamOrPlayer = 'team';
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
    currentValueLastUpdated = DateTime.now();
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
    return 'Contract($id)';
  }
}

class Portfolio extends Instrument {
  String name;
  bool public;
  List<Instrument> contracts;
  List<double> amounts;
  Map<String, dynamic> contractIdAmountMap;

  Portfolio(String portfolioId) : super(portfolioId);

  Portfolio.fromDocumentSnapshot(DocumentSnapshot snapshot) : super(snapshot.id) {
    Map<String, dynamic> data = snapshot.data();
    name = data['name'];
    public = data['public'];

    // contracts =
    //     data['contracts'].keys.map<Instrument>((String contractId) => Instrument(contractId)).toList();

    // amounts = data['contracts']
    //     .keys
    //     .map<double>((String contractId) => 1.0 * data['contracts'][contractId])
    //     .toList();

    // contractIdAmountMap = Map<String, dynamic>.from(data['contracts']);
  }

  Future<void> populateContracts() async {
    if (contracts == null) {
      print('Cannot get contracts - try adding portfolio from snapshot first');
      return;
    }
    List<Instrument> contractsNew = [];
    for (Instrument contract in contracts) {
      if (contract.id == 'cash') {
        contractsNew.add(Cash());
      } else {
        contractsNew.add(await getContractById(contract.id));
      }
    }
    contracts = contractsNew;

    pH = matrixMultiply(this.contracts.map((contract) => contract.pH).toList(), this.amounts);
    pD = matrixMultiply(this.contracts.map((contract) => contract.pD).toList(), this.amounts);
    pW = matrixMultiply(this.contracts.map((contract) => contract.pW).toList(), this.amounts);
    pM = matrixMultiply(this.contracts.map((contract) => contract.pM).toList(), this.amounts);
    pMax = matrixMultiply(this.contracts.map((contract) => contract.pMax).toList(), this.amounts);

    super.computeValueChange();
  }

  @override
  String toString() {
    return 'Portfolio(${contracts.toString()})';
  }
}
