import 'package:cloud_firestore/cloud_firestore.dart';

class Instrument {
  String name;
  double value;
  String id;

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

  void computeValues() {
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
}

class Contract extends Instrument {
  String name;
  String imageURL;
  double value;
  String contractType;
  String longShort;
  List<String> searchTerms;
  String contractID;

  // only for player contracts
  String team;

  // info to to be shown on left of tile
  String info1;
  String info2;
  String info3;

  setData(data) {
    imageURL = data['image'];

    pH = List<double>.from(data['pH'].map((item) => 1.0 * item).toList());
    pD = List<double>.from(data['pD'].map((item) => 1.0 * item).toList());
    pW = List<double>.from(data['pW'].map((item) => 1.0 * item).toList());
    pM = List<double>.from(data['pM'].map((item) => 1.0 * item).toList());
    pMax = List<double>.from(data['pMax'].map((item) => 1.0 * item).toList());

    if (data['type'].contains('long'))
      longShort = 'long';
    else
      longShort = 'short';

    searchTerms = data['search_terms'].cast<String>();

    super.computeValues();
  }

  @override
  String toString() {
    return 'Contract(${this.name})';
  }
}

class TeamContract extends Contract {
  String contractType = 'team';

  TeamContract.fromSnapshot(DocumentSnapshot snapshot) {

    id = snapshot.id;
    Map<String, dynamic> data = snapshot.data();
    
    if (data == null) {
      print('WARNING: TeamContract passed null data');
      return;
    }

    name = data['team_name'];
    info1 = "P ${data['played']}";
    info2 = "GD ${data['goal_difference'] > 0 ? '+' : '-'}${data['goal_difference'].abs()}";
    info3 = "PTS ${data['points']}";

    super.setData(data);
  }
}

class PlayerContract extends Contract {
  String contractType = 'player';

  PlayerContract.fromSnapshot(DocumentSnapshot snapshot) {

    id = snapshot.id;
    Map<String, dynamic> data = snapshot.data();

    if (data == null) {
      print('WARNING: PlayerContract passed null data');
      return;
    }
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

    super.setData(data);
  }
}
