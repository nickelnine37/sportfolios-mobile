import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/numerical/arrays.dart';
import '../../data/utils/casting.dart';
import '../api/requests.dart';
import '../lmsr/lmsr.dart';

String splitLongName(String name, int maxLen, String type) {
  if (name.length > maxLen) {
    List names = name.split(" ");
    if (names.length > 2) {
      if (type == 'player') {
        name = names.first + ' ' + names.last;
      } else {
        name = names.first + ' ' + names[1];
      }
    } else {
      if (type == 'player') {
        name = names.last;
      } else {
        name = names.first;
      }
    }
  }

  return name;
}

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
  Map<String, Map<String, dynamic>>? stats;
  Map<String, dynamic>? details;

  // ----- price attributes -----
  double? longPriceCurrent;
  Map<String, Array>? longPriceHist;
  Map<String, double>? longPriceReturnsHist;

  // ----- LMSR -----
  LMSR? currentLMSR;
  HistoricalLMSR? historicalLMSR;

  // ---- Players only ----
  TeamMarket? team;

  // ---- what's been run? -------
  bool firebaseMarketsRun = false;
  bool serverCurrentValuesRun = false;
  bool serverHistoricValuesRun = false;

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

  Future<void> getStats() async {
    String stats_id = id.split(':')[0] + id[id.length - 1];
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('stats').doc(stats_id).get();
    stats = Map<String, Map<String, dynamic>>.from(snapshot['stats']);
    details = Map<String, dynamic>.from(snapshot['details']);
  }

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
    name = splitLongName(snapshot['name'], 20, 'player');

    info1 = snapshot['country_flag'] + ' ' + snapshot['position'];
    info2 = "Hey";
    info3 = splitLongName(snapshot['team_name'], 15, 'team');

    team_id = '${snapshot['team_id']}:${snapshot['league_id']}:${snapshot['season_id']}T';

    firebaseMarketsRun = true;
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
      serverCurrentValuesRun = true;
    } else {
      print('Error: getCurrentHoldings(${id}) returned null');
    }
  }

  @override
  void setCurrentHoldings(Map<String, dynamic> currentHoldings) {
    currentLMSR = PlayerLMSR(n: currentHoldings['N'], b: currentHoldings['b']);
    longPriceCurrent = currentLMSR!.getLongValue();
    serverCurrentValuesRun = true;
  }

  @override
  Future<void> getHistoricalHoldings() async {
    Map<String, dynamic>? historicalHoldings = await getHistoricalHoldingsFromServer(id);
    if (historicalHoldings != null) {
      historicalLMSR = PlayerHisoricalLMSR(
          nhist: historicalHoldings['data']['N'], bhist: historicalHoldings['data']['b'], thist: historicalHoldings['time']);
      serverHistoricValuesRun = true;
    } else {
      print('Error: getCurrentHoldings(${id}) returned null');
    }
  }

  @override
  void setHistoricalHoldings(Map<String, dynamic> data, Map<String, List<int>> time) {
    historicalLMSR = PlayerHisoricalLMSR(nhist: data['N'], bhist: data['b'], thist: time);
    serverHistoricValuesRun = true;
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

    name = splitLongName(snapshot['name'], 20, 'team');
    info1 = "P ${snapshot['played']}";
    info2 = "GD ${snapshot['goal_difference'] > 0 ? '+' : '-'}${snapshot['goal_difference'].abs()}";
    info3 = "PTS ${snapshot['points']}";
    players = List<String>.from(snapshot['players'].map((playerId) => '$playerId:${snapshot['league_id']}:${snapshot['season_id']}}P'));
    firebaseMarketsRun = true;

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
      serverCurrentValuesRun = true;
    } else {
      print('Error: getCurrentHoldings(${id}) returned null');
    }
  }

  @override
  void setCurrentHoldings(Map<String, dynamic> currentHoldings) {
    currentLMSR = TeamLMSR(x: currentHoldings['x'], b: currentHoldings['b']);
    longPriceCurrent = currentLMSR!.getLongValue();
    serverCurrentValuesRun = true;
  }

  @override
  Future<void> getHistoricalHoldings() async {
    Map<String, dynamic>? historicalHoldings = await getHistoricalHoldingsFromServer(id);
    if (historicalHoldings != null) {
      historicalLMSR = TeamHistoricalLMSR(
          xhist: historicalHoldings['data']['x'], bhist: historicalHoldings['data']['b'], thist: historicalHoldings['time']);
      serverHistoricValuesRun = true;
    } else {
      print('Error: getCurrentHoldings(${id}) returned null');
    }
  }

  @override
  void setHistoricalHoldings(Map<String, dynamic> data, Map<String, List<int>> time) {
    historicalLMSR = TeamHistoricalLMSR(xhist: data['x'], bhist: data['b'], thist: time);
    serverHistoricValuesRun = true;
  }

  @override
  Future<TeamMarket?> getTeamInfo() async {
    return null;
  }
}
