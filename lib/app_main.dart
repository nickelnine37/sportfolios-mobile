import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/data_models/portfolios.dart';
import 'package:sportfolios_alpha/screens/home.dart';
import 'package:sportfolios_alpha/screens/leaderboard.dart';
import 'package:sportfolios_alpha/screens/portfolio/portfolio_page.dart';
import 'package:sportfolios_alpha/screens/settings.dart';

class AppMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppMainState();
  }
}

class _AppMainState extends State<AppMain> {
  int selectedPage = 0;
  final _pageOptions = [
    Home(),
    PortfolioPage(),
    Leaderboard(),
    Settings()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _pageOptions[selectedPage],
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.grey[200],
        currentIndex: selectedPage,
        onTap: (int index) {
          setState(() {
            selectedPage = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Portfolio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
      ),
    );
  }
}
