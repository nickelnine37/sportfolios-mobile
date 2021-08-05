import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../plots/mini_donut_chart.dart';
import '../portfolio/comments.dart';
import '../portfolio/holdings.dart';
import '../portfolio/performance.dart';
import '../../data/objects/portfolios.dart';
import 'leaderboard.dart';


class ViewPortfolio extends StatefulWidget {
  final Portfolio portfolio;

  ViewPortfolio({required this.portfolio});

  @override
  _ViewPortfolioState createState() => _ViewPortfolioState();
}

class _ViewPortfolioState extends State<ViewPortfolio> {
  Future<void>? portfoliosFuture;
  bool? liked;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // liked = widget.userInfo.likedPortfolios.contains(widget.portfolio.id);
    portfoliosFuture = _getPortfolioInfo();
  }

  Future<void> _getPortfolioInfo() async {
    await widget.portfolio.populateMarketsFirebase();
    await widget.portfolio.populateMarketsServer();
    widget.portfolio.getCurrentValue();
    widget.portfolio.getHistoricalValue();
  }

  @override
  Widget build(BuildContext context) {
    if (liked == null) {
      liked = context.read(likedPortfolioProvider).portfolios.contains(widget.portfolio.id);
    }

    return FutureBuilder(
      future: portfoliosFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              // automaticallyImplyLeading: false,
              iconTheme: IconThemeData(color: Colors.white),
              titleSpacing: 0,
              toolbarHeight: 110,
              title: Column(children: [
                // Padding(
                // padding: const EdgeInsets.only(left: 0.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 10),
                        Container(
                          height: 25,
                          width: 25,
                          child: MiniDonutChart(widget.portfolio, strokeWidth: 8),
                        ),
                        SizedBox(width: 17),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.portfolio.name, style: TextStyle(fontSize: 25.0, color: Colors.white)),
                            SizedBox(height: 2),
                            Text(
                              widget.portfolio.username,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // ),
              ]),
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                        icon: liked!
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red[400],
                                size: 30,
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 30,
                              ),
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() {
                                  loading = true;
                                });

                                if (liked!) {
                                  context.read(likedPortfolioProvider).removeFavorite(widget.portfolio.id);
                                  print('removing favourite: ${widget.portfolio.id}');
                                } else {
                                  context.read(likedPortfolioProvider).addNewFavorite(widget.portfolio.id);
                                  print('adding favourite: ${widget.portfolio.id}');
                                }

                                await Future.delayed(Duration(seconds: 1));

                                setState(() {
                                  loading = false;
                                  liked = !liked!;
                                });
                              }),
                    Container(
                      width: 10,
                      height: 10,
                      child: loading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : null,
                    )
                  ],
                ),
              ],
              bottom: TabBar(
                labelPadding: EdgeInsets.all(5),
                tabs: <Icon>[
                  Icon(Icons.donut_large, color: Colors.white, size: 21),
                  Icon(Icons.timeline, color: Colors.white, size: 24),
                  Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                ],
              ),
            ),
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Holdings(
                  portfolio: widget.portfolio,
                  owner: false,
                ),
                Performance(widget.portfolio),
                PortfolioComments(portfolio: widget.portfolio),
              ],
            ),
          ),
        );
      },
    );
  }
}
