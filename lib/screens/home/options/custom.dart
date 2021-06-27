import 'package:flutter/material.dart';
import '../../../data/objects/markets.dart';
import '../../../plots/payout_graph.dart';
import '../../../plots/price_chart.dart';
import 'market_details.dart';
import 'info_box.dart';
import '../../../utils/numerical/array_operations.dart';

import 'header.dart';

class CustomDetails extends StatefulWidget {
  final Market market;

  CustomDetails(this.market);

  @override
  _CustomDetailsState createState() => _CustomDetailsState();
}

class _CustomDetailsState extends State<CustomDetails> with AutomaticKeepAliveClientMixin<CustomDetails> {
  String helpText =
      'A custom market gives you full autonomy to design your own payout structure. Drag each bar on the payout graph up and down to create your desired payout. ';
  double lrPadding = 25;
  List<double> p1;
  List<double> p2;
  bool reversed = false;
  Map priceHistory;
  double graphWidth;
  double graphHeight = 150;
  bool locked = false;

  @override
  void initState() {
    p1 = range(widget.market.lmsr.n).map((int i) => 10.0).toList();
    p2 = range(widget.market.lmsr.n).map((int i) => 10.0).toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void updateHistory() {
    priceHistory = widget.market.lmsr.getHistoricalValue(p1);
  }

  void _makeSelection(Offset touchLocation) {
    int x = (widget.market.lmsr.n * touchLocation.dx / graphWidth).floor();
    if (x < 0) {
      x = 0;
    } else if (x > widget.market.lmsr.n - 1) {
      x = widget.market.lmsr.n;
    }
    double y = 10 * (1 - (touchLocation.dy - 20) / (graphHeight + 20));

    if (y < 0) {
      y = 0;
    }
    if (y > 10) {
      y = 10;
    }
    p2 = range(widget.market.lmsr.n).map((int i) => i == x ? y : p2[i]).toList();

    if (p2 != p1) {
      setState(() {
        p1 = p2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (graphWidth == null) {
      graphWidth = MediaQuery.of(context).size.width - 2 * lrPadding;
    }

    if (priceHistory == null) {
      updateHistory();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await widget.market.lmsr.updateCurrentX();
        await widget.market.lmsr.updateHistoricalX();
        await Future.delayed(Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10),
            PageHeader(
                p1,
                widget.market,
                InfoBox(title: 'Binary markets', pages: [
                  MiniInfoPage(
                      'A custom market gives you full autonomy to design your own payout structure. Drag each bar on the payout graph up and down to create your desired payout. ',
                      Icon(Icons.bar_chart, size: 80),
                      Colors.blue[600]),
                  MiniInfoPage(
                      'Hit the lock switch to keep your selected payout structure in place. Once locked, touch each bar to view the exact payout. You can also tap the reverse icon to flip the directionality of the cut-off.',
                      Transform.scale(
                          scale: 1.8,
                          child: Switch(
                            value: false,
                            onChanged: (value) {},
                          )),
                      Colors.grey[600]),
                  MiniInfoPage('You can also tap the reverse icon to flip the directionality of the cut-off.',
                      Icon(Icons.loop, size: 80), Colors.grey[700]),
                ])),
            Row(
              children: [
                Switch(
                  value: locked,
                  onChanged: (bool val) {
                    setState(() {
                      locked = val;
                    });
                  },
                ),
                Text('Lock payout')
              ],
            ),
            locked
                ? TrueStaticPayoutGraph(p1, Colors.blue, lrPadding, graphHeight, true, 10)
                : GestureDetector(
                    child: TrueStaticPayoutGraph(p1, Colors.blue, lrPadding, graphHeight, false, 10),
                    onVerticalDragStart: (DragStartDetails details) {
                      _makeSelection(details.localPosition);
                    },
                    onVerticalDragUpdate: (DragUpdateDetails details) {
                      _makeSelection(details.localPosition);
                    },
                    onTapDown: (TapDownDetails details) {
                      _makeSelection(details.localPosition);
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      _makeSelection(details.localPosition);
                    },
                    onPanEnd: (DragEndDetails details) {
                      setState(() {
                        updateHistory();
                      });
                    },
                    onTapUp: (TapUpDetails details) {
                      setState(() {
                        updateHistory();
                      });
                    },
                    onVerticalDragEnd: (DragEndDetails details) {
                      setState(() {
                        updateHistory();
                      });
                    },
                  ),
            SizedBox(height: 35),
            TabbedPriceGraph(priceHistory: priceHistory, times: widget.market.lmsr.times),
            SizedBox(height: 20),
            Divider(thickness: 2),
            PageFooter(widget.market)
          ],
        ),
      ),
    );
  }
}
