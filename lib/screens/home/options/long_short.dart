import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/dialogues.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';
import 'dart:math' as math;

import 'header.dart';
import 'info_box.dart';

class LongShortDetails extends StatefulWidget {
  final Contract contract;
  final String type;

  LongShortDetails(this.contract, this.type);

  @override
  _LongShortDetailsState createState() => _LongShortDetailsState();
}

class _LongShortDetailsState extends State<LongShortDetails> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String selectedContract = 'BACK';
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
          selectedContract = 'BACK';
          selectedQ = p1;
        } else {
          selectedContract = 'LAY';
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
        p1 = range(widget.contract.n).map((i) => 10 * math.exp(-i / 6)).toList();
      } else {
        p1 = range(widget.contract.n).map((i) => 10 * math.exp(-(widget.contract.n - i - 1) / 6)).toList();
      }
      p2 = p1.map((i) => 10 - i).toList();
    }

    if (selectedQ == null) {
      selectedQ = p1;
    }

    String helpText;
    if (widget.type == 'Long') {
      helpText =
          'A long contract pays out more and more the higher a team places in the league, up to a maxmimum payout of £10 for 1st place. This makes the BACK a great buy if you believe a team\'s potential is underestimated. Alternatively, you can take the opposite side of the bet by buying a LAY contract. This is similar to a short position in that it pays out more and more the lower a team finishes. Toggle these options on the payout graph to explore their respective payouts.';
    } else if (widget.type == 'Short') {
      helpText =
          'A short contract pays out more and more the lower a team places in the league, up to a maximum payout of £10 for last place. This makes the BACK a great buy if you believe a team\'s potential is overestimated. Alternatively, you can take the opposite side of the bet by buying a LAY contract. This is similar to a long position, in that it pays our more and more the higher a team finishes. Toggle these options on the payout graph to explore their respective payouts.';
    }

    double lrPadding = 25;

    Map priceHistory = widget.contract.getHistoricalValue(selectedQ);

    return DefaultTabController(
      length: 2,
      child: SingleChildScrollView(
        child: Column(
          //  mainAxisSize: MainAxisSize.min,
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
            PageHeader(
                selectedQ,
                widget.contract,
                InfoBox(
                  title: '${widget.type} contracts',
                  pages: widget.type == 'Long'
                      ? [
                          MiniInfoPage(
                              'A basic long contract (also known as a long BACK) pays out more and more the higher a team places in the league, up to a maxmimum payout of £10 for 1st place.',
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
                              'This makes the BACK a great buy if you believe a team\'s potential is underestimated. The more the team outperforms expectations, the more your contract will climb in value.',
                              Icon(Icons.trending_up, size: 80),
                              Colors.green[600]),
                          MiniInfoPage(
                              'Alternatively, you can take the opposite side of the bet by buying a LAY contract. The payout structure of this contract is the inverse of the BACK, meaning its price is always £10 minus the BACK price.',
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
                              'A basic short contract (also known as a short BACK) pays out more and more the lower a team places in the league, up to a maxmimum payout of £10 for last place.',
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
                              'This makes the short BACK a great buy if you believe a team\'s potential is overestimated. The more the team underperforms expectations, the more your contract will climb in value.',
                              Icon(Icons.trending_down, size: 80),
                              Colors.red[600]),
                          MiniInfoPage(
                              'Alternatively, you can take the opposite side of the bet by buying a LAY contract. The payout structure of this contract is the inverse of the BACK, meaning its price is always £10 minus the BACK price.',
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
                )),
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
            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}

