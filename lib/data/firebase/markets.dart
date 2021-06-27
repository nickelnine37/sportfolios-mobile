import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/requests.dart';
import '../objects/markets.dart';

Future<Market> getMarketById(String id) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection(id[id.length - 1] == 'T' ? 'teams' : 'players')
      .doc(id)
      .get();
  return Market.fromDocumentSnapshot(snapshot);
}

Future<DocumentSnapshot> getMarketSnapshotById(String id) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection(id[id.length - 1] == 'T' ? 'teams' : 'players')
      .doc(id)
      .get();
  return snapshot;
}

class MarketFetcher {
  DocumentSnapshot lastDocument;
  Query baseQuery;
  int leagueID;
  String marketType;
  List<Market> loadedResults = [];
  bool finished = false;
  List<Market> alreadyLoaded;

  void setData({List<Market> alreadyLoaded = null, String search = null}) {
    // work out whether this is a player or team market and order by different metric accordingly

    if (marketType == 'players') {
      baseQuery = baseQuery.orderBy('rating', descending: true).limit(10);
    } else {
      baseQuery = baseQuery.orderBy('points', descending: true).limit(10);
    }

    this.alreadyLoaded = alreadyLoaded;

    if (alreadyLoaded != null) {
      loadedResults.addAll(alreadyLoaded.where((Market market) => market.searchTerms.contains(search)));
    }
  }

  Future<void> get10() async {
    if (!finished) {
      QuerySnapshot results;

      if (loadedResults.length == 0) {
        results = await baseQuery.get();
      } else {
        results = await baseQuery.startAfterDocument(loadedResults.last.doc).get();
      }

      if (results.docs.length < 10) {
        finished = true;
      }

      if (results.docs.length > 0) {
        Map<String, double> prices = await getBackPrices(
            results.docs.map<String>((DocumentSnapshot snapshot) => snapshot.id).toList());
        Map<String, List> dailyPrices = await getDailyBackPrices(
            results.docs.map<String>((DocumentSnapshot snapshot) => snapshot.id).toList());
        loadedResults.addAll(
          results.docs.map<Market>((DocumentSnapshot snapshot) => Market.fromDocumentSnapshot(snapshot)
            ..setBackProperties(prices[snapshot.id], List<double>.from(dailyPrices[snapshot.id]))),
        );
      }
    }
  }
}

/// class for fetching markets when there is no particular serach term associated
class LeagueMarketFetcher extends MarketFetcher {
  int leagueID;
  String marketType;

  LeagueMarketFetcher(this.leagueID, this.marketType) {
    // set up basic query structure
    baseQuery = FirebaseFirestore.instance.collection(marketType).where('league_id', isEqualTo: leagueID);
    super.setData();
  }
}

/// class for fetching markets when there is no particular serach term associated
class LeagueSearchMarketFetcher extends MarketFetcher {
  String search;
  int leagueID;
  String marketType;
  List<Market> alreadyLoaded;

  LeagueSearchMarketFetcher({this.search, this.leagueID, this.marketType, this.alreadyLoaded}) {
    // set up basic query structure
    baseQuery = FirebaseFirestore.instance
        .collection(marketType)
        .where('league_id', isEqualTo: leagueID)
        .where('search_terms', arrayContains: search);

    super.setData(alreadyLoaded: this.alreadyLoaded, search: search);
  }
}


/// class for fetching markets when there is no particular serach term associated
class TeamPlayerMarketFetcher extends MarketFetcher {
  int teamId;
  String marketType = 'players';

  TeamPlayerMarketFetcher(this.teamId) {
    // set up basic query structure
    baseQuery = FirebaseFirestore.instance.collection('players').where('team_id', isEqualTo: teamId);
    super.setData();
  }
}

/// class for fetching markets when there is no particular serach term associated
class TeamPlayerSearchMarketFetcher extends MarketFetcher {
  String search;
  int teamId;
  List<Market> alreadyLoaded;

  TeamPlayerSearchMarketFetcher({this.search, this.teamId, this.alreadyLoaded}) {
    // set up basic query structure
    baseQuery = FirebaseFirestore.instance
        .collection('players')
        .where('team_id', isEqualTo: teamId)
        .where('search_terms', arrayContains: search);

    super.setData(alreadyLoaded: this.alreadyLoaded, search: search);
  }
}