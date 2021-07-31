import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/plots/mini_donut_chart.dart';
import 'package:sportfolios_alpha/screens/portfolio/holdings.dart';
import 'package:sportfolios_alpha/screens/portfolio/performance.dart';
import '../../data/objects/portfolios.dart';


class ViewPortfolio extends StatefulWidget {
  final Portfolio portfolio;
  ViewPortfolio(this.portfolio);

  @override
  _ViewPortfolioState createState() => _ViewPortfolioState();
}

class _ViewPortfolioState extends State<ViewPortfolio> {
  Future<void>? portfoliosFuture;

  @override
  void initState() {
    super.initState();
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
    return FutureBuilder(
      future: portfoliosFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              toolbarHeight: 110,
              title: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
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
                          Text(widget.portfolio.name, style: TextStyle(fontSize: 25.0, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
              bottom: TabBar(
                labelPadding: EdgeInsets.all(5),
                tabs: <Row>[
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Holdings', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.donut_large, color: Colors.white, size: 17)
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Performance', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.show_chart, color: Colors.white, size: 17)
                  ]),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
