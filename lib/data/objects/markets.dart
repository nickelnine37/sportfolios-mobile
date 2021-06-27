import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/data/firebase/markets.dart';
import 'package:sportfolios_alpha/data/lmsr/lmsr.dart';


class Market {
  // ----- basic attributes -----
  String id;
  String name;
  DocumentSnapshot doc;
  List<String> searchTerms;
  DateTime startDate;
  DateTime endDate;
  String type;

  // stats
  Map<String, dynamic> stats;

  // -----  Link attributes -----
  String team_id; // null for teams
  Market team;

  List<String> players; // null for players

  // ----- Visual attributes -----
  String info1;
  String info2;
  String info3;
  List<String> colours;
  String imageURL;

  // ----- LMSR attributes ------
  // length of quantity vector
  // int n;

  // back attributes
  double currentBackValue;
  List<double> dailyBackValue;

  // lmsr
  MarketLMSR lmsr;

  /// initialise market from id
  Market(this.id) {
    if (id == 'cash') {
      name = 'Cash';
    }
    else {
      type = id[id.length - 1] == 'T' ? 'team' : 'player';
    }
    lmsr = MarketLMSR(id);
  }

  /// initialise a market from a firebase snapshot
  Market.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();

    id = snapshot.id;
    doc = snapshot;
    lmsr = MarketLMSR(id);
    type = id[id.length - 1] == 'T' ? 'team' : 'player';


    colours = List<String>.from(data['colours']);
    searchTerms = List<String>.from(data['search_terms']);
    imageURL = data['image'];
    startDate = data['start_date'].toDate();
    endDate = data['end_date'].toDate();

    if (snapshot.id[snapshot.id.length - 1] == 'P') {
      initPlayerInfo(data);
    } else {
      initTeamInfo(data);
    }
  }

  Future<void> getTeamSnapshot() async {
    team = await getMarketById(team_id);
    await team.getBackProperties();
  }

  // get statistics for team and player
  Future<void> getStats() async {
    String idStats = id.split(':')[0] + id[id.length - 1];
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('stats')
      .doc(idStats)
      .get();
    stats = snapshot.data();
  }


  void addDocumentSnapshotData(DocumentSnapshot snapshot) {
    assert(id == snapshot.id);

    Map<String, dynamic> data = snapshot.data();

    doc = snapshot;

    colours = List<String>.from(data['colours']);
    searchTerms = List<String>.from(data['search_terms']);
    imageURL = data['image'];
    startDate = data['start_date'].toDate();
    endDate = data['end_date'].toDate();

    if (snapshot.id[snapshot.id.length - 1] == 'P') {
      initPlayerInfo(data);
    } else {
      initTeamInfo(data);
    }
  }

  /// helper function for setting some back properties which are required
  /// to display the mini graph and scroll prices
  void setBackProperties(double currentBValue, List<double> dailyBValue) {
    currentBackValue = currentBValue;
    dailyBackValue = dailyBValue;
  }

  Future<void> getBackProperties() async {
    currentBackValue = (await getBackPrices([id]))[id];
    dailyBackValue = await List<double>.from((await getDailyBackPrices([id]))[id]);
  }

  /// initialise player info from firebase data
  void initPlayerInfo(Map<String, dynamic> data) {
    if (data['name'].length > 20) {
      List names = data['name'].split(" ");
      if (names.length > 2)
        name = names.first + ' ' + names.last;
      else
        name = names.last;
    } else
      name = data['name'];
    print(data['name']);
    print(name);

    info1 = data['country_flag'] + ' ' + data['position'];
    info2 = "${data['rating']}";

    if (data['team'].length > 20)
      info3 = data['team'].split(" ")[0];
    else
      info3 = data['team'];
    team_id = '${data['team_id']}:${data['league_id']}:${data['season_id']}T' ;
    team = Market(team_id);
  }

  /// initialise team info from firebase data
  void initTeamInfo(Map<String, dynamic> data) {

    name = data['name'];
    info1 = "P ${data['played']}";
    info2 = "GD ${data['goal_difference'] > 0 ? '+' : '-'}${data['goal_difference'].abs()}";
    info3 = "PTS ${data['points']}";
    players = List<String>.from(
        data['players'].map((playerId) => '$playerId:${data['league_id']}:${data['season_id']}}P'));
  }

  @override
  String toString() {
    return 'Market($id)';
  }
}
