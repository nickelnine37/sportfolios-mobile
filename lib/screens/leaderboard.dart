import 'package:flutter/material.dart';

/// The portfolio leaderboard page!
/// TODO: Implement!
class Leaderboard extends StatefulWidget {
  Leaderboard({Key key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Leaderboard')),);
  }
}