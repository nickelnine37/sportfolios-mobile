// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/firebase/portfolios.dart';
import 'package:sportfolios_alpha/plots/mini_donut_chart.dart';

import '../../data/objects/portfolios.dart';

class Leaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Text('Week', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              Tab(icon: Text('Month', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
              Tab(icon: Text('Max', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            ],
          ),
          title: Text('Portfolio Leaderboard', style: TextStyle(color: Colors.white)),
        ),
        body: TabBarView(
          children: [
            LeaderboardScroll('w'),
            LeaderboardScroll('m'),
            LeaderboardScroll('M'),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class LeaderboardScroll extends StatefulWidget {
  final String timeHorizon;
  late ReturnsPortfolioFetcher portfolioFetcher;

  LeaderboardScroll(this.timeHorizon) {
    portfolioFetcher = ReturnsPortfolioFetcher(timeHorizon);
  }

  @override
  _LeaderboardScrollState createState() => _LeaderboardScrollState();
}

class _LeaderboardScrollState extends State<LeaderboardScroll> with AutomaticKeepAliveClientMixin {
  Future<void>? portfoliosFuture;
  List<Portfolio>? portfolios;
  ScrollController _scrollController = ScrollController(initialScrollOffset: 50);

  @override
  void initState() {
    super.initState();
    portfoliosFuture = widget.portfolioFetcher.get10();
    _scrollController.addListener(_scrollListener);
  }

  /// helper function: has the user scrolled to the bottom of the page?
  bool _scrolledToBottom() {
    return _scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange;
  }

  /// listener for scroll controller
  void _scrollListener() async {
    if (!widget.portfolioFetcher.finished) {
      if (_scrolledToBottom()) {
        // await Future.delayed(Duration(seconds: 1), () => 12);
        // don't reassign the future here - it's just for the initial building
        await widget.portfolioFetcher.get10();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: portfoliosFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          int nTiles = widget.portfolioFetcher.loadedResults.length + 1;
          // make space for the apology tile
          if (nTiles == 1) {
            nTiles += 1;
          }

          return ListView.separated(
            controller: _scrollController,
            itemCount: nTiles,
            itemBuilder: (context, index) {
               if (index == nTiles - 1) {
                // final tile contains the loading spinner
                if (widget.portfolioFetcher.finished) {
                  return Container(height: 0);
                } else {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              }
              if (widget.portfolioFetcher.loadedResults.length == 0) {
                // no results here
                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(child: Text("Sorry, no results :'(")),
                );
              } else {
                return ListTile(title: Text(widget.portfolioFetcher.loadedResults[index].name));
              }
            },
            separatorBuilder: (context, index) => Divider(
              thickness: 2,
              height: 2,
            ),
          );
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
