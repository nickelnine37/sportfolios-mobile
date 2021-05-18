import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/dialogues.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';
import 'dart:math' as math;

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
            PageHeader(selectedQ, widget.contract, widget.type, helpText),
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
                          lrPadding, graphHeight, false),
                    );
                  }),
            ),
            SizedBox(height: 25,),
            TabbedPriceGraph(priceHistory: priceHistory), 
                              SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  final List<double> quantity;
  final Contract contract;
  final String type;
  final String helpText;

  PageHeader(this.quantity, this.contract, this.type, this.helpText);

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 80,
            child: Center(
              child: Column(
                children: [
                  Text(
                    formatCurrency(contract.getCurrentValue(quantity), 'GBP'),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                  ),
                  Text('per contract', style: TextStyle(fontSize: 12),)
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('BUY', style: TextStyle(color: Colors.white)),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  elevation: 100,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                  context: context,
                  builder: (context) {
                    return Container(
                      child: Text('Hey'),
                    );
                  },
                );
              },
              color: Colors.green[400],
              minWidth: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
          Container(
            width: 80,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.info_outline, size: 23),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return BasicDialog(
                          title: type + ' contracts: information',
                          description: helpText,
                          buttonText: 'OK',
                          action: () {},
                        );
                      });
                },
              ),
            ),
          ),
        ]);
  }
}
