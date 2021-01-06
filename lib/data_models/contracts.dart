import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Contract {
  String name;
  String imageURL;
  double price;

  List<double> price24h;
  double changePrice;
  double changePercent;
  bool bull;

  // info to to be shown on left of tile
  String info1;
  String info2;
  String info3;

  String contractType;

  setData(data) {
    this.imageURL = data['image'];
    this.price24h =
        List<double>.from(data['price24'].map((item) => 1.0 * item).toList());
    this.price = this.price24h[this.price24h.length - 1];
    this.bull = (this.price > this.price24h[0]);
    this.changePrice = this.price - this.price24h[0];
    this.changePercent = 1 - this.price / this.price24h[0];
  }
}

class TeamContract extends Contract {
  String contractType = 'team';

  TeamContract.fromMap(Map<String, dynamic> data) {
    this.name = data['team_name'];
    info1 = "P ${data['played']}";
    info2 =
        "GD ${data['goal_difference'] > 0 ? '+' : '-'}${data['goal_difference'].abs()}";
    info3 = "PTS ${data['points']}";

    super.setData(data);
  }
}

class PlayerContract extends Contract {
  String contractType = 'player';

  PlayerContract.fromMap(Map<String, dynamic> data) {
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
