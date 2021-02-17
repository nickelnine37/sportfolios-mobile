import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/firebase/contracts.dart';
import 'package:sportfolios_alpha/data/models/base.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';

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

  // info to to be shown on left of summary tile
  String info1;
  String info2;
  String info3;

  Contract(String contractId) : super(contractId);

  Contract.fromDocumentSnapshot(DocumentSnapshot snapshot) : super(snapshot.id) {
    Map<String, dynamic> data = snapshot.data();

    // pH = List<double>.from(data['pH'].map((item) => 1.0 * item));
    // pD = List<double>.from(data['pD'].map((item) => 1.0 * item));
    // pW = List<double>.from(data['pW'].map((item) => 1.0 * item));
    // pM = List<double>.from(data['pM'].map((item) => 1.0 * item));
    // pMax = List<double>.from(data['pMax'].map((item) => 1.0 * item));

    pH = data['pH'].cast<double>();
    pD = data['pD'].cast<double>();
    pW = data['pW'].cast<double>();
    pM = data['pM'].cast<double>();
    pMax = data['pMax'].cast<double>();

    if (data['type'].contains('long'))
      longOrShort = 'long';
    else
      longOrShort = 'short';

    if (data['type'].contains('player')) {
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

    super.computeValueChange();
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

    print(3);

    contracts =
        data['contracts'].keys.map<Instrument>((String contractId) => Instrument(contractId)).toList();

    print(4);

    amounts = data['contracts']
        .keys
        .map<double>((String contractId) => 1.0 * data['contracts'][contractId])
        .toList();

    print(5);

    contractIdAmountMap = Map<String, dynamic>.from(data['contracts']);
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
