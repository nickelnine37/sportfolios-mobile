import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import '../objects/markets.dart';

Future<Market> getMarketById(String id) async {
  if (id.contains('T')) {
    return TeamMarket.fromDocumentSnapshot(await FirebaseFirestore.instance.collection('teams').doc(id).get());
  } else {
    return PlayerMarket.fromDocumentSnapshot(await FirebaseFirestore.instance.collection('players').doc(id).get());
  }
}

Future<DocumentSnapshot> getMarketSnapshotById(String id) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection(id[id.length - 1] == 'T' ? 'teams' : 'players').doc(id).get();
  return snapshot;
}

class MarketFetcher {
  // DocumentSnapshot? lastDocument;
  late Query baseQuery;
  int? leagueID;
  String? marketType;
  List<Market> loadedResults = [];
  bool finished = false;
  List<Market>? alreadyLoaded;

  void setData({List<Market>? alreadyLoaded = null, String? search = null}) {
    this.alreadyLoaded = alreadyLoaded;

    if (alreadyLoaded != null) {
      loadedResults.addAll(alreadyLoaded.where((Market market) => market.searchTerms!.contains(search)));
    }
  }

  Future<void> get10() async {
    if (!finished) {
      QuerySnapshot results;

      if (loadedResults.length == 0) {
        results = await baseQuery.get();
      } else {
        results = await baseQuery.startAfterDocument(loadedResults.last.doc!).get();
      }

      if (results.docs.length < 10) {
        finished = true;
      }

      if (results.docs.length > 0) {
        Map<String, dynamic>? holdings =
            await getMultipleCurrentHoldings(results.docs.map<String>((DocumentSnapshot snapshot) => snapshot.id).toList());

        List<String> loadedIds = loadedResults.map<String>((Market market) => market.id).toList();

        results.docs.forEach((QueryDocumentSnapshot snapshot) {
          if (!loadedIds.contains(snapshot.id)) {
            if (snapshot.id.contains('T')) {
              loadedResults.add(TeamMarket.fromDocumentSnapshot(snapshot)..setCurrentHoldings(holdings![snapshot.id]));
            } else {
              loadedResults.add(PlayerMarket.fromDocumentSnapshot(snapshot)..setCurrentHoldings(holdings![snapshot.id]));
            }
          }
        });

      }
    }
  }
}

/// class for fetching markets when there is no particular serach term associated
class LeagueMarketFetcher extends MarketFetcher {
  int? leagueID;
  String? marketType;
  String? sortByField;
  bool? sortByDescending;

  LeagueMarketFetcher({
    required this.leagueID,
    required this.marketType,
    required this.sortByField,
    required this.sortByDescending,
  }) {
    // set up basic query structure
    baseQuery = FirebaseFirestore.instance
        .collection(marketType!)
        .where('league_id', isEqualTo: leagueID)
        .orderBy(sortByField!, descending: sortByDescending!)
        .limit(10);
    super.setData();
  }
}

/// class for fetching markets when there is no particular serach term associated
class LeagueSearchMarketFetcher extends MarketFetcher {
  String? search;
  int? leagueID;
  String? marketType;
  List<Market>? alreadyLoaded;

  LeagueSearchMarketFetcher({this.search, this.leagueID, this.marketType, this.alreadyLoaded}) {
    // set up basic query structure
    baseQuery = FirebaseFirestore.instance
        .collection(marketType!)
        .where('league_id', isEqualTo: leagueID)
        .where('search_terms', arrayContains: search);

    super.setData(alreadyLoaded: this.alreadyLoaded, search: search);
  }
}

/// class for fetching markets when there is no particular serach term associated
class TeamPlayerMarketFetcher extends MarketFetcher {
  int teamId;
  String sortByField;
  bool sortByDescending;

  TeamPlayerMarketFetcher({
    required this.teamId,
    required this.sortByField,
    required this.sortByDescending,
  }) {
    // set up basic query structure
    baseQuery = FirebaseFirestore.instance
        .collection('players')
        .where('team_id', isEqualTo: teamId)
        .orderBy(sortByField, descending: sortByDescending)
        .limit(10);
    ;
    super.setData();
  }
}

/// class for fetching markets when there is no particular serach term associated
class TeamPlayerSearchMarketFetcher extends MarketFetcher {
  String? search;
  int? teamId;
  List<Market>? alreadyLoaded;

  TeamPlayerSearchMarketFetcher({this.search, this.teamId, this.alreadyLoaded}) {
    // set up basic query structure
    baseQuery =
        FirebaseFirestore.instance.collection('players').where('team_id', isEqualTo: teamId).where('search_terms', arrayContains: search);

    super.setData(alreadyLoaded: this.alreadyLoaded, search: search);
  }
}
