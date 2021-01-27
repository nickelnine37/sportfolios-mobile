import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';

Future<Contract> getContractById(String id) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('contracts').doc(id).get();
  return Contract.fromDocumentSnapshot(snapshot);
}

class ContractFetcher {

  DocumentSnapshot lastDocument;
  Query baseQuery;
  int leagueID;
  String contractType;
  List<Contract> loadedResults = [];
  bool finished = false;

  void setData() {
    // work out whether this is a player or team contract and order by different metric accordingly
    if (contractType.contains('player')) {
      baseQuery = baseQuery.orderBy('rating', descending: true).limit(10);
    } else {
      baseQuery = baseQuery.orderBy('points', descending: true).limit(10);
    }
  }

  Future<void> get10() async {
    if (!finished) {
      QuerySnapshot results;

      if (lastDocument == null) {
        results = await baseQuery.get();
      } else {
        results = await baseQuery.startAfterDocument(lastDocument).get();
      }

      if (results.docs.length < 10) {
        finished = true;
      }

      if (results.docs.length > 0) {
        lastDocument = results.docs.last;

        loadedResults.addAll(
          results.docs.map<Contract>((DocumentSnapshot snapshot) => Contract.fromDocumentSnapshot(snapshot)),
        );
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
    baseQuery = FirebaseFirestore.instance
        .collection('contracts')
        .where('league_id', isEqualTo: leagueID)
        .where('type', isEqualTo: contractType);

    super.setData();
  }
}

/// class for fetching contracts when there is no particular serach term associated
class SearchQueryContractFetcher extends ContractFetcher {
  String search;
  int leagueID;
  String contractType;

  SearchQueryContractFetcher(this.search, this.leagueID, this.contractType) {
    // set up basic query structure
    baseQuery = FirebaseFirestore.instance
        .collection('contracts')
        .where('league_id', isEqualTo: leagueID)
        .where('type', isEqualTo: contractType)
        .where('search_terms', arrayContains: search);

    super.setData();
  }
}
