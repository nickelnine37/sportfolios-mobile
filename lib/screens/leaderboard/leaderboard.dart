// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/firebase/portfolios.dart';
import 'package:sportfolios_alpha/plots/mini_donut_chart.dart';
import 'package:sportfolios_alpha/screens/leaderboard/view_portfolio.dart';
import 'package:sportfolios_alpha/utils/strings/number_format.dart';

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

  LeaderboardScroll(this.timeHorizon) {}

  @override
  _LeaderboardScrollState createState() => _LeaderboardScrollState();
}

class _LeaderboardScrollState extends State<LeaderboardScroll> with AutomaticKeepAliveClientMixin {
  Future<void>? portfoliosFuture;
  List<Portfolio>? portfolios;
  ScrollController _scrollController = ScrollController(initialScrollOffset: 50);
  ReturnsPortfolioFetcher? portfolioFetcher;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  /// helper function: has the user scrolled to the bottom of the page?
  bool _scrolledToBottom() {
    return _scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange;
  }

  /// listener for scroll controller
  void _scrollListener() async {
    if (!portfolioFetcher!.finished) {
      if (_scrolledToBottom()) {
        // await Future.delayed(Duration(seconds: 1), () => 12);
        // don't reassign the future here - it's just for the initial building
        await portfolioFetcher!.get10();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (portfolioFetcher == null) {
      portfolioFetcher = ReturnsPortfolioFetcher(widget.timeHorizon);
      portfoliosFuture = portfolioFetcher!.get10();
    }

    return FutureBuilder(
      future: portfoliosFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          int nTiles = portfolioFetcher!.loadedResults.length + 1;
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
                if (portfolioFetcher!.finished || (portfolioFetcher!.loadedResults.length == 0)) {
                  return Container(height: 0);
                } else {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              }
              if (portfolioFetcher!.loadedResults.length == 0) {
                // no results here
                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(child: Text("Sorry, no results :'(")),
                );
              } else {
                return PortfolioTile(
                  portfolio: portfolioFetcher!.loadedResults[index],
                  returnsPeriod: widget.timeHorizon,
                  index: index,
                );
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
  final String returnsPeriod;
  final int index;

  final double height = 100.0;
  final double imageHeight = 50.0;
  final EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 10);

  final double upperTextSize = 16.0;
  final double lowerTextSize = 12.0;
  final double spacing = 3.0;

  PortfolioTile({required this.portfolio, required this.returnsPeriod, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
          return ViewPortfolio(portfolio);
        }));
      },
      child: Container(
        height: height,
        padding: padding,
        child: Row(children: [
          SizedBox(width: 10),
          Text('${index + 1}'),
          SizedBox(width: 25),
          Container(
            height: 40,
            width: 40,
            child: MiniDonutChart(portfolio, strokeWidth: 9),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 20, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(portfolio.name, style: TextStyle(fontSize: upperTextSize)),
                          SizedBox(height: spacing),
                          Text(
                            portfolio.username,
                            style: TextStyle(fontSize: lowerTextSize, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(portfolio.currentValue, 'GBP'),
                            style: TextStyle(fontSize: upperTextSize),
                          ),
                          SizedBox(height: spacing),
                          Text(
                              '${portfolio.periodReturns[returnsPeriod]! < 0 ? '-' : '+'}${formatPercentage(portfolio.periodReturns[returnsPeriod]!.abs(), 'GBP')}',
                              style: TextStyle(
                                  fontSize: 12, color: portfolio.periodReturns[returnsPeriod]! >= 0 ? Colors.green[300] : Colors.red[300])),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
