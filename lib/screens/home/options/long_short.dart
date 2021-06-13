import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';
import 'dart:math' as math;

import '../market_details.dart';
import 'header.dart';
import 'info_box.dart';

class LongShortDetails extends StatefulWidget {
  final Market market;
  final String type;

  LongShortDetails(this.market, this.type);

  @override
  _LongShortDetailsState createState() => _LongShortDetailsState();
}

class _LongShortDetailsState extends State<LongShortDetails> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String selectedMarket = 'BACK';
  List<double> selectedQ;
  double graphHeight = 150;

  List<double> p1;
  List<double> p2;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          selectedMarket = 'BACK';
          selectedQ = p1;
        } else {
          selectedMarket = 'LAY';
          selectedQ = p2;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (p1 == null) {
      if (widget.type == 'Long') {
        p1 = range(widget.market.n).map((i) => 10 * math.exp(-i / 6)).toList();
      } else {
        p1 = range(widget.market.n).map((i) => 10 * math.exp(-(widget.market.n - i - 1) / 6)).toList();
      }
      p2 = p1.map((i) => 10 - i).toList();
    }

    if (selectedQ == null) {
      selectedQ = p1;
    }

    double lrPadding = 25;

    Map priceHistory = widget.market.getHistoricalValue(selectedQ);

    return DefaultTabController(
      length: 2,
      child: RefreshIndicator(
        onRefresh: () async {
          if (DateTime.now().difference(widget.market.currentXLastUpdated).inSeconds > 10) {
            Map<String, dynamic> holdings = await getcurrentX(widget.market.id);
            widget.market.setCurrentX(List<double>.from(holdings['x']), holdings['b']);
            Map<String, dynamic> historicalX = await getHistoricalX(widget.market.id);
            widget.market.setHistoricalX(historicalX['xhist'], historicalX['bhist']);
            await Future.delayed(Duration(seconds: 1));
            setState(() {});
          } else {
            await Future.delayed(Duration(seconds: 1));
            print('Refreshed too fast!!');
          }
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            // shrinkWrap: true,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10),
              Container(
                // width: MediaQuery.of(context).size.width * 0.7,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 30,
                    padding: EdgeInsets.only(bottom: 5, top: 2, left: 3, right: 3),
                    child: TabBar(
                      labelColor: Colors.grey[900],
                      unselectedLabelColor: Colors.grey[400],
                      indicatorColor: Colors.grey[600],
                      indicatorWeight: 1,
                      controller: _tabController,
                      labelPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(child: Text('BACK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                        Tab(child: Text('LAY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                ),
              ),
              PageHeader(selectedQ, widget.market, LongShortInfoBox(widget.type)),
              Container(
                child: AnimatedBuilder(
                    animation: _tabController.animation,
                    builder: (BuildContext context, snapshot) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: lrPadding),
                        child: TrueStaticPayoutGraph(
                            matrixMultiplyDoubleDouble(
                              [p1, p2],
                              [1 - _tabController.animation.value, _tabController.animation.value],
                            ),
                            Colors.blue,
                            lrPadding,
                            graphHeight,
                            true),
                      );
                    }),
              ),
              SizedBox(
                height: 25,
              ),
              TabbedPriceGraph(priceHistory: priceHistory),
              SizedBox(height: 20),
              Divider(thickness: 2),
              PageFooter(widget.market),
            ],
          ),
        ),
      ),
    );
  }
}

class LongShortInfoBox extends StatelessWidget {
  final String type;

  LongShortInfoBox(this.type);

  @override
  Widget build(BuildContext context) {
    return InfoBox(
      title: '${type} markets',
      pages: type == 'Long'
          ? [
              MiniInfoPage(
                  'A basic long market (also known as a long BACK) pays out more and more the higher a team places in the league, up to a maxmimum payout of £10 for 1st place.',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Icon(Icons.signal_cellular_alt, size: 80)),
                      Text(
                        '1    2    3 ',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  Colors.blue[600]),
              MiniInfoPage(
                  'This makes the BACK a great buy if you believe a team\'s potential is underestimated. The more the team outperforms expectations, the more your market will climb in value.',
                  Icon(Icons.trending_up, size: 80),
                  Colors.green[600]),
              MiniInfoPage(
                  'Alternatively, you can take the opposite side of the bet by buying a LAY market. The payout structure of this market is the inverse of the BACK, meaning its price is always £10 minus the BACK price.',
                  Column(
                    children: [
                      Icon(Icons.signal_cellular_alt, size: 80),
                      Text(
                        ' 1    2     3',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  Colors.blue[600])
            ]
          : [
              MiniInfoPage(
                  'A basic short market (also known as a short BACK) pays out more and more the lower a team places in the league, up to a maxmimum payout of £10 for last place.',
                  Column(
                    children: [
                      Icon(Icons.signal_cellular_alt, size: 80),
                      Text(
                        '  18   19   20',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  Colors.blue[600]),
              MiniInfoPage(
                  'This makes the short BACK a great buy if you believe a team\'s potential is overestimated. The more the team underperforms expectations, the more your market will climb in value.',
                  Icon(Icons.trending_down, size: 80),
                  Colors.red[600]),
              MiniInfoPage(
                  'Alternatively, you can take the opposite side of the bet by buying a LAY market. The payout structure of this market is the inverse of the BACK, meaning its price is always £10 minus the BACK price.',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Icon(Icons.signal_cellular_alt, size: 80)),
                      Text(
                        '18   19   20',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  Colors.blue[600])
            ],
    );
  }
}
