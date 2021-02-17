import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';

Future<Portfolio> getPortfolioById(String portfoliloId) async {
  DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('portfolios').doc(portfoliloId).get();
  print(2);
  return Portfolio.fromDocumentSnapshot(snapshot);
}

Future<Portfolio> getDeepPortfolioById(String portfolioId) async {
  print(1);
  Portfolio portfolio = await getPortfolioById(portfolioId);
  portfolio.populateContracts();
  return portfolio;
}

Future<void> addNewPortfolio(String name, bool public) async {
  String uid = AuthService().currentUid;
  CollectionReference portfoliosCollection = FirebaseFirestore.instance.collection('portfolios');
  try {
    DocumentReference newPortfolio = await portfoliosCollection.add({
      'name': name,
      'public': public,
      'contracts': {'cash': 500},
      'user': uid
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

Future<String> buyContract(Map<String, dynamic> purchaseForm) async {
  DocumentReference portfolioRefernce =
      FirebaseFirestore.instance.collection('portfolios').doc(purchaseForm['portfolioId']);
  DocumentSnapshot portfolioSnapshot = await portfolioRefernce.get();

  if (portfolioSnapshot.data()['contracts']['cash'] < purchaseForm['price'])
    return 'Insufficient funds';
  else {
    try 
      {
      portfolioRefernce
          .update({'contracts.cash': portfolioSnapshot.data()['contracts']['cash'] - purchaseForm['price']});
      portfolioRefernce
          .update({'contracts.${purchaseForm['contractId']}': purchaseForm['units']});
    } on Exception catch (e) {
          print('Error buying contract: $e');
          return 'Connection error';
    }
    return 'Success';
  }
}