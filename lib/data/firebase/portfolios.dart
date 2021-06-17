import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';

Future<Portfolio> getPortfolioById(String portfoliloId) async {
  return Portfolio.fromDocumentSnapshot(
      await FirebaseFirestore.instance.collection('portfolios').doc(portfoliloId).get());
}

Future<void> addNewPortfolio(String name, bool public) async {
  String uid = AuthService().currentUid;
  CollectionReference portfoliosCollection = FirebaseFirestore.instance.collection('portfolios');
  try {
    DocumentReference newPortfolio = await portfoliosCollection.add({
      'user': uid,
      'name': name,
      'public': public,
      'markets': <String>['cash'],
      'holdings': {
        'cash': <double>[500.0]
      },
      'history': [
        {
          'market': 'cash',
          'time': (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
          'quantity': <double>[500.0],
        }
      ],
      'weekly_return': 0.0,
      'monthly_return': 0.0,
      'maxly_return': 0.0,
      'weekly_return_updated': DateTime.now(),
      'monthly_return_updated': DateTime.now(),
      'maxly_return_updated': DateTime.now(),
      'weekly_price_history': List<double>.generate(60, (int i) => 500.0),
      'monthly_price_history': List<double>.generate(60, (int i) => 500.0),
      'maxly_price_history': List<double>.generate(60, (int i) => 500.0),
    });

    print('Added new portfolio: ${newPortfolio.id}');

    try {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'portfolios': FieldValue.arrayUnion([newPortfolio.id])
      });
      print('Successfully updated user portfolio list');
    } on Exception catch (e) {
      print('Error updaing user portfolio list: $e');
    }
  } on Exception catch (e) {
    print('Error adding new portfolio: $e');
  }
}

class PortfolioFetcher {
  DocumentSnapshot lastDocument;
  Query baseQuery;
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
        loadedResults.addAll(
          results.docs
              .map<Portfolio>((DocumentSnapshot snapshot) => Portfolio.fromDocumentSnapshot(snapshot)),
        );
      }
    }
  }
}

class WeeklyPortfolioFetcher extends PortfolioFetcher {
  WeeklyPortfolioFetcher() {
    baseQuery = FirebaseFirestore.instance
        .collection('portfolios')
        .orderBy('weekly_return', descending: true)
        .limit(10);
  }
}

class MonthlyPortfolioFetcher extends PortfolioFetcher {
  WeeklyPortfolioFetcher() {
    baseQuery = FirebaseFirestore.instance
        .collection('portfolios')
        .orderBy('monthly_return', descending: true)
        .limit(10);
  }
}

class MaxlyPortfolioFetcher extends PortfolioFetcher {
  WeeklyPortfolioFetcher() {
    baseQuery = FirebaseFirestore.instance
        .collection('portfolios')
        .orderBy('maxly_return', descending: true)
        .limit(10);
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
