import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/numerical/arrays.dart';
import '../../data/utils/casting.dart';
import '../api/requests.dart';
import '../lmsr/lmsr.dart';


abstract class Market {
  // ----- core attributes -----
  late String id;
  DocumentSnapshot? doc;

  // ----- basic attributes -----
  String? name;
  List<String>? searchTerms;
  DateTime? startDate;
  DateTime? endDate;

  // ----- Visual attributes -----
  String? info1;
  String? info2;
  String? info3;
  List<String>? colours;
  String? imageURL;

  // stats
  Map<String, dynamic>? stats;

  // ----- price attributes -----
  double? longPriceCurrent;
  Map<String, Array>? longPriceHist;
  Map<String, double>? longPriceReturnsHist;

  // ----- LMSR -----
  LMSR? currentLMSR;
  HistoricalLMSR? historicalLMSR;

  // ---- Players only ---- 
  TeamMarket? team;

  void addSnapshotInfo(DocumentSnapshot snapshot) {
    doc = snapshot;
    id = snapshot.id;
    name = snapshot['name'];

    if (snapshot['colours'] == null) {
      colours = ['#1544B8', '#1544B8', '#183690', '#183690', '#183690', '#183690', '#1544B8'];
    } else {
      colours = List<String>.from(snapshot['colours']);
    }

    searchTerms = List<String>.from(snapshot['search_terms']);
    imageURL = snapshot['image'];
    startDate = snapshot['start_date'].toDate();
    endDate = snapshot['end_date'].toDate();

    longPriceCurrent = 10.0 * snapshot['long_price_current']!;
    longPriceHist = castHistArray(snapshot['long_price_hist']);
    longPriceReturnsHist = <String, double>{
      'd': snapshot['long_price_returns_d'],
      'w': snapshot['long_price_returns_w'],
      'm': snapshot['long_price_returns_m'],
      'M': snapshot['long_price_returns_M']
    };

  }

  Future<void> getSnapshotInfo();

  Future<void> getCurrentHoldings();

  void setCurrentHoldings(Map<String, dynamic> currentHoldings);

  Future<void> getHistoricalHoldings();

  void setHistoricalHoldings(Map<String, dynamic> data, Map<String, List<int>> time);

  Future<void> getTeamInfo();
}

class PlayerMarket extends Market {
  String? team_id;

  PlayerMarket(String idd) {
    id = idd;
  }

  PlayerMarket.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    addSnapshotInfo(snapshot);
  }

  @override
  void addSnapshotInfo(DocumentSnapshot snapshot) {
    super.addSnapshotInfo(snapshot);
    if (snapshot['name'].length > 20) {
      List names = snapshot['name'].split(" ");
      if (names.length > 2)
        name = names.first + ' ' + names.last;
      else
        name = names.last;
    } else
      name = snapshot['name'];

    info1 = snapshot['country_flag'] + ' ' + snapshot['position'];
    info2 = "Hey";

    if (snapshot['team_name'].length > 20)
      info3 = snapshot['team_name'].split(" ")[0];
    else
      info3 = snapshot['team_name'];

    team_id = '${snapshot['team_id']}:${snapshot['league_id']}:${snapshot['season_id']}T';

  }

  Future<void> getSnapshotInfo() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('players').doc(id).get();
    addSnapshotInfo(snapshot);
  }

  @override
  Future<void> getCurrentHoldings() async {
    Map<String, dynamic>? currentHoldings = await getCurrentHoldingsFromServer(id);
    if (currentHoldings != null) {
      currentLMSR = PlayerLMSR(n: currentHoldings['N'], b: currentHoldings['b']);
      longPriceCurrent = currentLMSR!.getLongValue();
    } else {
      print('Error: getCurrentHoldings(${id}) returned null');
    }
  }

  @override
  void setCurrentHoldings(Map<String, dynamic> currentHoldings) {
    currentLMSR = PlayerLMSR(n: currentHoldings['N'], b: currentHoldings['b']);
    longPriceCurrent = currentLMSR!.getLongValue();
  }

  @override
  Future<void> getHistoricalHoldings() async {
    Map<String, dynamic>? historicalHoldings = await getHistoricalHoldingsFromServer(id);
    if (historicalHoldings != null) {
      historicalLMSR = PlayerHisoricalLMSR(
          nhist: historicalHoldings['data']['N'], bhist: historicalHoldings['data']['b'], thist: historicalHoldings['time']);
    } else {
      print('Error: getCurrentHoldings(${id}) returned null');
    }
  }

  @override
  void setHistoricalHoldings(Map<String, dynamic> data, Map<String, List<int>> time) {
    historicalLMSR = PlayerHisoricalLMSR(nhist: data['N'], bhist: data['b'], thist: time);
  }

  @override
  String toString() {
    return 'PlayerMarket(${id})';
  }

  @override
  Future<void> getTeamInfo() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('teams').doc(team_id).get();
    team = TeamMarket.fromDocumentSnapshot(snapshot);
  }
}

class TeamMarket extends Market {
  List<String>? players;

  TeamMarket(String idd) {
    id = idd;
  }

  TeamMarket.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    addSnapshotInfo(snapshot);
  }

  @override
  void addSnapshotInfo(DocumentSnapshot snapshot) {
    super.addSnapshotInfo(snapshot);
    name = snapshot['name'];
    info1 = "P ${snapshot['played']}";
    info2 = "GD ${snapshot['goal_difference'] > 0 ? '+' : '-'}${snapshot['goal_difference'].abs()}";
    info3 = "PTS ${snapshot['points']}";
    players = List<String>.from(snapshot['players'].map((playerId) => '$playerId:${snapshot['league_id']}:${snapshot['season_id']}}P'));
  }

  Future<void> getSnapshotInfo() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('teams').doc(id).get();
    addSnapshotInfo(snapshot);
  }

  @override
  String toString() {
    return 'TeamMarket(${id})';
  }

  @override
  Future<void> getCurrentHoldings() async {
    Map<String, dynamic>? currentHoldings = await getCurrentHoldingsFromServer(id);
    if (currentHoldings != null) {
      currentLMSR = TeamLMSR(x: currentHoldings['x'], b: currentHoldings['b']);
      longPriceCurrent = currentLMSR!.getLongValue();
    } else {
      print('Error: getCurrentHoldings(${id}) returned null');
    }
  }

  @override
  void setCurrentHoldings(Map<String, dynamic> currentHoldings) {
    currentLMSR = TeamLMSR(x: currentHoldings['x'], b: currentHoldings['b']);
    longPriceCurrent = currentLMSR!.getLongValue();
  }

  @override
  Future<void> getHistoricalHoldings() async {
    Map<String, dynamic>? historicalHoldings = await getHistoricalHoldingsFromServer(id);
    if (historicalHoldings != null) {
      historicalLMSR = TeamHistoricalLMSR(
          xhist: historicalHoldings['data']['x'], bhist: historicalHoldings['data']['b'], thist: historicalHoldings['time']);
    } else {
      print('Error: getCurrentHoldings(${id}) returned null');
    }
  }

  @override
  void setHistoricalHoldings(Map<String, dynamic> data, Map<String, List<int>> time) {
    historicalLMSR = TeamHistoricalLMSR(xhist: data['x'], bhist: data['b'], thist: time);
  }

  @override
  Future<TeamMarket?> getTeamInfo() async {
    return null;
  }
}

// class TeamMarket extends Market {
//   void initInfo() {
//     name = doc['name'];
//     info1 = "P ${doc['played']}";
//     info2 = "GD ${doc['goal_difference'] > 0 ? '+' : '-'}${doc['goal_difference'].abs()}";
//     info3 = "PTS ${doc['points']}";
//     players = List<String>.from(doc['players'].map((playerId) => '$playerId:${doc['league_id']}:${doc['season_id']}}P'));
//   }

//   @override
//   String toString() {
//     return 'TeamMarket($id)';
//   }
// }


// class PlayerMarket extends Market {



// }