import 'package:cloud_firestore/cloud_firestore.dart';
import '../objects/portfolios.dart';
import '../../utils/authentication/authenication_provider.dart';

Future<Portfolio?> getPortfolioById(String portfoliloId) async {
  DocumentSnapshot portfolio_doc = await FirebaseFirestore.instance.collection('portfolios').doc(portfoliloId).get();
  if (portfolio_doc.exists) {
    print('Got him!: ${portfoliloId}');
    return Portfolio.fromDocumentSnapshot(portfolio_doc);
  } else {
    print('Cannot get portfolio: ${portfoliloId}');
    return null;
  }
}

Future<void> deletePortfolio(String portfolioId) async {
  await FirebaseFirestore.instance.collection('portfolios').doc(portfolioId).update({'active': false});
  await FirebaseFirestore.instance.collection('user').doc(AuthService().currentUid).update({
    'portfolios': FieldValue.arrayRemove([portfolioId])
  });
}

abstract class PortfolioFetcher {
  List<Portfolio> loadedResults = [];
  bool finished = false;

  Future<void> get10();
}

class FavoritesPortfolioFetcher extends PortfolioFetcher {
  late List<String> portfolioIds;
  int n10s = 0;

  FavoritesPortfolioFetcher({this.portfolioIds=const []});

  void setFavorites(List<String> newPortfolioIds){
    portfolioIds = newPortfolioIds;
  }

  @override
  Future<void> get10() async {
    if (!finished) {
      for (int i = n10s * 10; i < (n10s + 1) * 10; i++) {
        if (i == portfolioIds.length) {
          finished = true;
          break;
        }
        await FirebaseFirestore.instance.collection('portfolios').doc(portfolioIds[i]).get().then((snapshot) {
          loadedResults.add(Portfolio.fromDocumentSnapshot(snapshot));
        }).catchError((error) {
          print('Error adding portfolio: ${error}');
        });
        ;
      }
    }
  }
}

class QueryPortfolioFetcher extends PortfolioFetcher {
  DocumentSnapshot? lastDocument;
  late Query baseQuery;

  @override
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
        loadedResults.addAll(results.docs.map<Portfolio>((DocumentSnapshot snapshot) => Portfolio.fromDocumentSnapshot(snapshot)));
      }
    }
  }
}

class ReturnsPortfolioFetcher extends QueryPortfolioFetcher {
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

class ContainingPortfolioFetcher extends QueryPortfolioFetcher {
  WeeklyPortfolioFetcher(String marketId) {
    baseQuery = FirebaseFirestore.instance
        .collection('portfolios')
        .where('active', isEqualTo: true)
        .where('public', isEqualTo: true)
        .where('markets', arrayContains: marketId)
        .orderBy('current_value', descending: true)
        .limit(10);
  }
}
