import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:sportfolios_alpha/tests.dart';
// import 'package:sportfolios_alpha/utils/numerical/arrays.dart';
import 'screens/leaderboard/leaderboard.dart';
import 'screens/portfolio/portfolio_page.dart';
import 'screens/settings.dart';
import 'screens/home/home.dart';

/// Main app widget. This is the four pages, Home, Portfolio, LeaderBoard, Settings
/// along the bottom, and the ability to switch between them
class AppMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppMainState();
  }
}

class _AppMainState extends State<AppMain> {
  int _selectedPage = 0;

  // These are the widgets that lead to each section
  final _pages = [
    Home(),
    PortfolioPage(),
    Leaderboard(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // body: _pages[_selectedPage],
      body: IndexedStack(
        index:_selectedPage,
        children:_pages
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.grey[200],
        currentIndex: _selectedPage,
        onTap: (int index) {
          setState(() {
            _selectedPage = index;
          });
        },

        // Bottom Bar icons
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.donut_large), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
      ),
    );
  }
}

// class AppMain extends StatefulWidget {
//   AppMain({Key? key}) : super(key: key);

//   @override
//   _AppMainState createState() => _AppMainState();
// }

// class _AppMainState extends State<AppMain> {

//   Future<void>? marketFuture;
//   late Market market;
//   late Portfolio portfolio;

//   @override
//   void initState() { 
//     marketFuture = getMarketFuture();
//     super.initState();
//   }

//   Future<void> getMarketFuture() async {
//     // DocumentSnapshot doc = await FirebaseFirestore.instance.collection('teams').doc('1:8:18378T').get();
//     // market = TeamMarket.fromDocumentSnapshot(doc);
//     // DocumentSnapshot doc = await FirebaseFirestore.instance.collection('players').doc('1001:9:18432P').get();
//     // market = PlayerMarket.fromDocumentSnapshot(doc);
//     // await market.getCurrentHoldings();
//     // await market.getHistoricalHoldings();
//     // print(market.historicalLMSR!.getHistoricalValue(LMSRTradeArgs.forLongShort(true)));
//     // print(market.historicalLMSR!.getHistoricalValue(LMSRTradeArgs.forClassic(Array.fromTrueDynamicList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]))));
    
//     DocumentSnapshot doc = await FirebaseFirestore.instance.collection('portfolios').doc('QTtfoOTg6IQI0cg8hiX3').get();

//     portfolio = Portfolio.fromDocumentSnapshpot(doc);

//     await portfolio.populateMarketsFirebase();
//     await portfolio.populateMarketsServer();

//     print(portfolio.getCurrentValue());

//     print(portfolio.getHistoricalValue());

//     await Future.delayed(Duration(seconds: 1));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: marketFuture,
//       builder: (BuildContext context, AsyncSnapshot snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return Scaffold(body: Center(child: Text('${portfolio.name}')));
//         }
//         else if (snapshot.hasError) {
//           return Scaffold(body: Center(child: Text(snapshot.error.toString())),);
//         }
//         else{
//           return Scaffold(body: Center(child: CircularProgressIndicator()),);
//         }
//       },
//     );
//   }
// }
