import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Contract {
  String name;
  String imageURL;
  double price;
  String contractType;
  String longShort;

  // info to to be shown on left of tile
  String info1;
  String info2;
  String info3;

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




  setData(data) {
    this.imageURL = data['image'];
    this.pH = List<double>.from(
        data['pH']?.map((item) => 1.0 * item)?.toList() ?? []);
    this.pD = List<double>.from(
        data['pD']?.map((item) => 1.0 * item)?.toList() ?? []);
    this.pW = List<double>.from(
        data['pW']?.map((item) => 1.0 * item)?.toList() ?? []);
    this.pM = List<double>.from(
        data['pM']?.map((item) => 1.0 * item)?.toList() ?? []);
    this.pMax = List<double>.from(
        data['pMax']?.map((item) => 1.0 * item)?.toList() ?? []);

    this.price = this.pH.last;

    hourValueChange = (this.price - this.pH.first);
    dayValueChange = (this.price - this.pD.first);
    weekValueChange = (this.price - this.pW.first);
    monthValueChange = (this.price - this.pM.first);
    totalValueChange = (this.price - this.pMax.first);

    hourReturn = hourValueChange / this.pH.first;
    dayReturn = hourValueChange / this.pD.first;
    weekReturn = hourValueChange / this.pW.first;
    monthReturn = hourValueChange / this.pM.first;
    totalReturn = hourValueChange / this.pMax.first;

    if (data['type'].contains('long')) {
      longShort = 'long';
    }
    else {
      longShort = 'short';
    }
  }

  @override
  String toString() {
    return 'Contract(${this.name})';
  }
}

class TeamContract extends Contract {
  String contractType = 'team';

  TeamContract.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      print('WARNING: TeamContract passed null data');
      return;
    }

    this.name = data['team_name'];
    this.info1 = "P ${data['played']}";
    this.info2 =
        "GD ${data['goal_difference'] > 0 ? '+' : '-'}${data['goal_difference'].abs()}";
    this.info3 = "PTS ${data['points']}";

    super.setData(data);
  }
}

class PlayerContract extends Contract {
  String contractType = 'player';

  PlayerContract.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      print('WARNING: PlayerContract passed null data');
      return;
    }
    if (data['name'].length > 24) {
      List names = data['name'].split(" ");
      if (names.length > 2)
        this.name = names[0] + ' ' + names[names.length - 1];
      else
        this.name = names[names.length - 1];
    } else
      this.name = data['name'];

    this.info1 = data['country_flag'] + ' ' + data['position'];
    this.info2 = "${data['rating']}";

    if (data['team'].length > 20)
      this.info3 = data['team'].split(" ")[0];
    else
      this.info3 = data['team'];

    super.setData(data);
  }
}

Future<List<Contract>> get10Contracts(
    {@required String contractType,
    @required int leagueID,
    @required DocumentSnapshot lastDocument}) async {
  List<Contract> newContracts = [];
  QuerySnapshot results;
  Query query;

  if (contractType == 'player_long' || contractType == 'player_short') {
    query = FirebaseFirestore.instance
        .collection('contracts')
        .where('league_id', isEqualTo: leagueID)
        .where('type', isEqualTo: contractType)
        .orderBy('rating', descending: true)
        .limit(10);
  } else if (contractType == 'team_long' || contractType == 'team_short') {
    query = FirebaseFirestore.instance
        .collection('contracts')
        .where('league_id', isEqualTo: leagueID)
        .where('type', isEqualTo: contractType)
        .orderBy('points', descending: true)
        .limit(10);
  } else
    throw ErrorDescription(
        'contractType must be "player_long", "player_short", "team_long" or "team_short"');

  if (lastDocument == null)
    results = await query.get();
  else
    results = await query.startAfterDocument(lastDocument).get();

  if (results.docs.isEmpty) return newContracts;

  lastDocument = results.docs[results.docs.length - 1];

  results.docs.forEach((result) {
    if (contractType == 'player_long' || contractType == 'player_short') {
      newContracts.add(PlayerContract.fromMap(result.data()));
    } else if (contractType == 'team_long' || contractType == 'team_short') {
      newContracts.add(TeamContract.fromMap(result.data()));
    }
  });

  await Future.delayed(Duration(seconds: 2), () => 12);

  return newContracts;
}
