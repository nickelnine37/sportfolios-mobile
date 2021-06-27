import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/objects/portfolios.dart';
import 'pie_chart.dart';
import 'leaderboard_plots.dart';

class Leaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Text('1w', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              Tab(icon: Text('1m', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              Tab(icon: Text('Max', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            ],
          ),
          title: Text('Leaderboard', style: TextStyle(color: Colors.white)),
        ),
        body: TabBarView(
          children: [
            LeaderboardScroll('1w'),
            LeaderboardScroll('1m'),
            LeaderboardScroll('Max'),
          ],
        ),
      ),
    );
  }
}

class LeaderboardScroll extends StatefulWidget {
  final String timeHorizon;

  LeaderboardScroll(this.timeHorizon);

  @override
  _LeaderboardScrollState createState() => _LeaderboardScrollState();
}

class _LeaderboardScrollState extends State<LeaderboardScroll> with AutomaticKeepAliveClientMixin{
  Future<List<Portfolio>>? portfoliosFuture;
  List<Portfolio>? portfolios;

  @override
  void initState() {
    // set portfoliosFuture
    super.initState();
    portfoliosFuture = getPortfolios();
  }

  Future<List<Portfolio>> getPortfolios() async {
    // run firebase queires here
    // use await and return the portfolio objects
    late QuerySnapshot results;

    if (widget.timeHorizon == 'd') {
      // set results
    } else if (widget.timeHorizon == 'm') {
      // set results
    } else if (widget.timeHorizon == 'M') {
      // set results
    }
    // simulate delay
    await Future.delayed(Duration(seconds: 1));
    // return results.docs.map((DocumentSnapshot doc) => Portfolio.fromDocumentSnapshot(doc)).toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: portfoliosFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          // loading is done
          portfolios = snapshot.data;
          return Center(child: Text('${widget.timeHorizon} Done')); // ListView<PortfolioTile>? SingleChildScrollView<Column(PortfolioTile)>?
        } else {
          // loading is not done
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}


class PortfolioTile extends StatelessWidget {
  final Portfolio portfolio;
  final int position;

  PortfolioTile(this.portfolio, this.position);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            children: [
              Container(child: Text('${position}', style: TextStyle(fontSize: 20.0)), padding: EdgeInsets.all(10.0)),
              Container(
                child: Icon(
                  Icons.favorite,
                  color: Colors.green,
                  size: 65.0,
                  semanticLabel: 'Text to announce in accessibility modes',
                ),
                padding: EdgeInsets.only(right: 10.0),
              ),
              Column(
                children: [
                  Container(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('TequilaFan21', style: TextStyle(fontSize: 20)),
                    ),
                    padding: EdgeInsets.all(2.0),
                    width: 180,
                  ),
                  Container(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Liverpool', style: TextStyle(fontSize: 16)),
                    ),
                    padding: EdgeInsets.all(2.0),
                    width: 180,
                  ),
                  Container(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('21-03-21', style: TextStyle(fontSize: 12)),
                    ),
                    padding: EdgeInsets.all(2.0),
                    width: 180,
                  ),
                ],
              ),
              Spacer(),
              Container(
                // Pie Chart holder
                child: MiniDonutChart(portfolio),
                padding: EdgeInsets.only(right: 10),
                // child: Text('Hello'),
              ),
            ],
          ),
          color: Colors.white,
          padding: EdgeInsets.all(10.0),
          margin: EdgeInsets.all(0),
          width: double.infinity,
        ),
        Container(
          child: HomeWidget(),
        ),
        Divider(
          thickness: 2,
          height: 1,
          color: Colors.grey[300],
        ),
        Text('Text 2'),
        Text('Text 3'),
      ],
    );
  }
}
