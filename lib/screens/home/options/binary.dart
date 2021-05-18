import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/dialogues.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';
import 'dart:math' as math;

class BinaryDetails extends StatefulWidget {
  final Contract contract;

  BinaryDetails(this.contract);

  @override
  _BinaryDetailsState createState() => _BinaryDetailsState();
}

class _BinaryDetailsState extends State<BinaryDetails> with AutomaticKeepAliveClientMixin<BinaryDetails> {
  String helpText =
      'A binary contract has a payout of either £10 or £0, based on whether a team finishes higher or lower than a chosen league position. Design your own binary contract by dragging the cut-off in the payout graph. Tap the flip icon to reverse the directionality.';
  double lrPadding = 25;
  List<double> p1;
  List<double> p2;
  bool reversed = false;
  double graphHeight = 150;

  @override
  void initState() {
    p1 = range(widget.contract.n).map((int i) => i < widget.contract.n / 2 ?  10.0 : 0.0).toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double graphWidth = MediaQuery.of(context).size.width - 2 * lrPadding;

    Map priceHistory = widget.contract.getHistoricalValue(p1);


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 10),
          PageHeader(p1, widget.contract, 'Binary', helpText),
          IconButton(
            icon: Icon(Icons.loop),
            onPressed: () {
              setState(() {
                reversed = !reversed;
                p1 = p1.map((i) => 10 - i).toList();
              });
            },
          ),
          GestureDetector(
            child: TrueStaticPayoutGraph(p1, Colors.blue, lrPadding, graphHeight, false),
            onPanUpdate: (DragUpdateDetails details) {
              double ii = widget.contract.n * details.localPosition.dx / graphWidth;
              p2 = range(widget.contract.n)
                  .map((int i) => i > ii ? (reversed ? 10.0 : 0.0) : (reversed ? 0.0 : 10.0))
                  .toList();
              if (reversed) {
                p2[widget.contract.n - 1] = 10;
              } else {
                p2[0] = 10;
              }
              if (p2 != p1) {
                setState(() {
                  p1 = p2;
                });
              }
            },
          ),
          SizedBox(height: 35),
          TabbedPriceGraph(priceHistory: priceHistory),
          SizedBox(height: 20)
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
                  Text(
                    'per contract',
                    style: TextStyle(fontSize: 12),
                  )
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
