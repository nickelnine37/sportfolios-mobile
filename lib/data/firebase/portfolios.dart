import 'package:cloud_firestore/cloud_firestore.dart';
import '../objects/portfolios.dart';
import '../../providers/authenication_provider.dart';

Future<Portfolio?> getPortfolioById(String portfoliloId) async {
  DocumentSnapshot portfolio_doc = await FirebaseFirestore.instance.collection('portfolios').doc(portfoliloId).get();
  if (portfolio_doc.exists) {
    return Portfolio.fromDocumentSnapshot(portfolio_doc);
  } else {
    return null;
  }
}

Future<void> deletePortfolio(String portfolioId) async {
  await FirebaseFirestore.instance.collection('portfolios').doc(portfolioId).update({'active': false});
  await FirebaseFirestore.instance.collection('user').doc(AuthService().currentUid).update({
    'portfolios': FieldValue.arrayRemove([portfolioId])
  });
}


class PortfolioFetcher {

  DocumentSnapshot? lastDocument;
  late Query baseQuery;
  List<Portfolio> loadedResults = [];
  bool finished = false;


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
        loadedResults.addAll(results.docs.map<Portfolio>((DocumentSnapshot snapshot) =>  Portfolio.fromDocumentSnapshot(snapshot)));
      }

    }
  }

}

class ReturnsPortfolioFetcher extends PortfolioFetcher {

  late String timeHorizon;

  ReturnsPortfolioFetcher(this.timeHorizon) {

    baseQuery = FirebaseFirestore.instance
        .collection('portfolios')
        .where('active', isEqualTo: true)
        .where('public', isEqualTo: true)
        .orderBy('returns_${timeHorizon}', descending: true)
        .limit(10);
  } 


}


class ContainingPortfolioFetcher extends PortfolioFetcher {
  WeeklyPortfolioFetcher(String marketId) {
    baseQuery = FirebaseFirestore.instance
        .collection('portfolios')
        .where('active', isEqualTo: true)
        .where('public', isEqualTo: true)
        .where('markets', arrayContains: marketId)
        .orderBy('returns_M', descending: true)
        .limit(10);
  }
}
