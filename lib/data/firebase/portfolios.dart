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

// Future<void> addNewPortfolio(String? name, bool public) async {
//   String uid = AuthService().currentUid;
// CollectionReference portfoliosCollection = FirebaseFirestore.instance.collection('portfolios');
// try {
//   DocumentReference newPortfolio = await portfoliosCollection.add({
//     'user': uid,
//     'name': name,
//     'public': public,
//     'cash': 500.0,
//     'current_value': 500.0,
//     'holdings': {},
//     'transactions': [],
//     'returns_d': 0.0,
//     'returns_w': 0.0,
//     'returns_m': 0.0,
//     'returns_M': 0.0
//   });

//   print('Added new portfolio: ${newPortfolio.id}');

//   try {
//     FirebaseFirestore.instance.collection('users').doc(uid).update({
//       'portfolios': FieldValue.arrayUnion([newPortfolio.id])
//     });
//     print('Successfully updated user portfolio list');
//   } on Exception catch (e) {
//     print('Error updaing user portfolio list: $e');
//   }
// } on Exception catch (e) {
//   print('Error adding new portfolio: $e');
// }
// }

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
        results = await baseQuery.startAfterDocument(loadedResults.last.doc!).get();
      }

      if (results.docs.length < 10) {
        finished = true;
      }

      if (results.docs.length > 0) {
        loadedResults.addAll(
          results.docs.map<Portfolio>((DocumentSnapshot snapshot) => Portfolio.fromDocumentSnapshot(snapshot)),
        );
      }
    }
  }
}

class WeeklyPortfolioFetcher extends PortfolioFetcher {
  WeeklyPortfolioFetcher() {
    baseQuery = FirebaseFirestore.instance.collection('portfolios').orderBy('weekly_return', descending: true).limit(10);
  }
}

class MonthlyPortfolioFetcher extends PortfolioFetcher {
  WeeklyPortfolioFetcher() {
    baseQuery = FirebaseFirestore.instance.collection('portfolios').orderBy('monthly_return', descending: true).limit(10);
  }
}

class MaxlyPortfolioFetcher extends PortfolioFetcher {
  WeeklyPortfolioFetcher() {
    baseQuery = FirebaseFirestore.instance.collection('portfolios').orderBy('maxly_return', descending: true).limit(10);
  }
}

class ContainingPortfolioFetcher extends PortfolioFetcher {
  WeeklyPortfolioFetcher(String marketId) {
    baseQuery = FirebaseFirestore.instance
        .collection('portfolios')
        .where('search_terms', arrayContains: marketId)
        .orderBy('maxly_return', descending: true)
        .limit(10);
  }
}
