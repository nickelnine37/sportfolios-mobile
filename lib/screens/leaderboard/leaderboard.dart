import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'portfolio_scroll.dart';
import '../../utils/authentication/authenication_provider.dart';

final likedPortfolioProvider = ChangeNotifierProvider<LikedPortfolioChangeNotifier>((ref) {
  return LikedPortfolioChangeNotifier();
});

class LikedPortfolioChangeNotifier with ChangeNotifier {
  List<String> _likedPortfolios = [];

  LikedPortfolioChangeNotifier() {
    FirebaseFirestore.instance.collection('users').doc(AuthService().currentUid).get().then((snapshot) {
      _likedPortfolios = List<String>.from(snapshot['liked_portfolios']);
      print('Successfully added likedPortfolios: ${_likedPortfolios}');
    }).catchError((error) {
      print('Error getting user info: ${error}');
    });
  }

  List<String> get portfolios => _likedPortfolios;

  void addNewFavorite(String newPortfolioId) {
    if (!_likedPortfolios.contains(newPortfolioId)) {
      _likedPortfolios.add(newPortfolioId);
      notifyListeners();
      FirebaseFirestore.instance.collection('users').doc(AuthService().currentUid).update(
        {
          'liked_portfolios': FieldValue.arrayUnion([newPortfolioId])
        },
      );
    }
  }

  void removeFavorite(String portfolioId) {
    if (_likedPortfolios.contains(portfolioId)) {
      _likedPortfolios.remove(portfolioId);
      notifyListeners();
      FirebaseFirestore.instance.collection('users').doc(AuthService().currentUid).update(
        {
          'liked_portfolios': FieldValue.arrayRemove([portfolioId])
        },
      );
    }
  }
}

class Leaderboard extends StatefulWidget {
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    context.read(likedPortfolioProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                  icon: Icon(
                Icons.public,
                color: Colors.white,
              )),
              Tab(
                  icon: Icon(
                Icons.favorite,
                color: Colors.white,
              )),
            ],
          ),
          title: Text('Portfolio Leaderboard', style: TextStyle(color: Colors.white, fontSize: 26)),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            GlobalLeaderboardScroll(),
            LikedLeaderboardScroll(),
          ],
        ),
      ),
    );
  }
}
