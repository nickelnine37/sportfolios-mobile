import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/home/home.dart';
import 'package:sportfolios_alpha/screens/leaderboard.dart';
import 'package:sportfolios_alpha/screens/portfolio/portfolio_page.dart';
import 'package:sportfolios_alpha/screens/settings.dart';

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
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _pages[_selectedPage],
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
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
      ),
    );
  }
}
