import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:sportfolios_alpha/data/firebase/contracts.dart';
import 'package:sportfolios_alpha/data/models/base.dart';

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

  @override
  Instrument populate(DocumentSnapshot snapshot) {
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

    super.populate(snapshot);
    return this;
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

  Contract(String contractId) {
    id = contractId;
  }

  @override
  Contract populate(DocumentSnapshot snapshot) {
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

    super.populate(snapshot);
    return this;
  }

  @override
  String toString() {
    return 'Contract($id)';
  }
}


class Portfolio extends Instrument {
  String name;
  bool public;
  List<Contract> contracts;

  Portfolio(String portfolioId) {
    id = portfolioId;
  }

  @override
  Portfolio populate(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    name = data['name'];
    public = data['public'];
    contracts = data['contracts'].map((String contractId) => Contract(contractId));
    return this;
  }

  Future<Portfolio> populateDeep (DocumentSnapshot snapshot) async {
    Map<String, dynamic> data = snapshot.data();
    name = data['name'];
    public = data['public'];
    
    contracts = [];
    for (String contractId in data['contracts']) {
      contracts.add(await getContractById(contractId));
    }
    return this;
  }
}
