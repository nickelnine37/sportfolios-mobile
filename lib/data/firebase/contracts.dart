import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';


Future<Contract> getContractById(String id) async {
  DocumentSnapshot snapshot;
  if (id[id.length - 1] == 'T') {
    snapshot = await FirebaseFirestore.instance.collection('teams').doc(id).get();
  } else {
    snapshot = await FirebaseFirestore.instance.collection('players').doc(id).get();
  }

   Map<String, double> prices = await getBackPrices([snapshot.id]);
   Map<String, Map> dailyPrices = await getDailyBackPrices([snapshot.id]);

  return Contract.fromDocumentSnapshotAndPrices(snapshot, prices[snapshot.id], dailyPrices[snapshot.id]);
}

class ContractFetcher {
  DocumentSnapshot lastDocument;
  Query baseQuery;
  int leagueID;
  String contractType;
  List<Contract> loadedResults = [];
  bool finished = false;
  List<Contract> alreadyLoaded;

  void setData({ List<Contract> alreadyLoaded=null, String search=null}) {
    // work out whether this is a player or team contract and order by different metric accordingly

    if (contractType == 'players') {
      baseQuery = baseQuery.orderBy('rating', descending: true).limit(10);
    } else {
      baseQuery = baseQuery.orderBy('points', descending: true).limit(10);
    }

    this.alreadyLoaded = alreadyLoaded;

    if (alreadyLoaded != null) {
      loadedResults.addAll(alreadyLoaded.where((Contract contract) => contract.searchTerms.contains(search)));
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

        Map<String, double> prices = await getBackPrices(results.docs.map<String>((DocumentSnapshot snapshot) => snapshot.id).toList());
        Map<String, Map> dailyPrices = await getDailyBackPrices(results.docs.map<String>((DocumentSnapshot snapshot) => snapshot.id).toList());
        loadedResults.addAll(
          results.docs.map<Contract>((DocumentSnapshot snapshot) => Contract.fromDocumentSnapshotAndPrices(snapshot, prices[snapshot.id], dailyPrices[snapshot.id])),
        );
                print(prices);        

      }
    }
  }
}

/// class for fetching contracts when there is no particular serach term associated
class DefaultContractFetcher extends ContractFetcher {
  int leagueID;
  String contractType;

  DefaultContractFetcher(this.leagueID, this.contractType) {

    // set up basic query structure
    baseQuery = FirebaseFirestore.instance.collection(contractType).where('league_id', isEqualTo: leagueID);
    super.setData();
  }
}

/// class for fetching contracts when there is no particular serach term associated
class SearchQueryContractFetcher extends ContractFetcher {
  String search;
  int leagueID;
  String contractType;
  List<Contract> alreadyLoaded;

  SearchQueryContractFetcher({this.search, this.leagueID, this.contractType, this.alreadyLoaded}) {

    // set up basic query structure
    baseQuery = FirebaseFirestore.instance
        .collection(contractType)
        .where('league_id', isEqualTo: leagueID)
        .where('search_terms', arrayContains: search);

    super.setData(alreadyLoaded: this.alreadyLoaded, search: search);
  }
}
