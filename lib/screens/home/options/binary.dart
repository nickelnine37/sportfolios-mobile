import 'package:flutter/material.dart';
import '../../../data/objects/markets.dart';
import '../../../plots/payout_graph.dart';
import '../../../plots/price_chart.dart';
import 'market_details.dart';
import '../../../utils/numerical/array_operations.dart';

import 'header.dart';
import 'info_box.dart';

class BinaryDetails extends StatefulWidget {
  final Market? market;

  BinaryDetails(this.market);

  @override
  _BinaryDetailsState createState() => _BinaryDetailsState();
}

class _BinaryDetailsState extends State<BinaryDetails> with AutomaticKeepAliveClientMixin<BinaryDetails> {
  String helpText =
      'A binary market has a payout of either £10 or £0, based on whether a team finishes higher or lower than a chosen league position. Design your own binary market by dragging the cut-off in the payout graph. Tap the flip icon to reverse the directionality.';
  double lrPadding = 25;
  List<double>? p1;
  List<double>? p2;
  bool reversed = false;
  double graphHeight = 150;
  bool locked = false;
  double? graphWidth;

  @override
  void initState() {
    p1 = range(widget.market!.lmsr.n).map((int i) => i < widget.market!.lmsr.n! / 2 ? 10.0 : 0.0).toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateBars(Offset position) {
    double ii = widget.market!.lmsr.n! * position.dx / graphWidth!;
    p2 = range(widget.market!.lmsr.n)
        .map((int i) => i > ii ? (reversed ? 10.0 : 0.0) : (reversed ? 0.0 : 10.0))
        .toList();
    if (reversed) {
      p2![widget.market!.lmsr.n! - 1] = 10;
    } else {
      p2![0] = 10;
    }
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
    Map<String, List<double>>? priceHistory = widget.market!.lmsr.getHistoricalValue(p1);

    return RefreshIndicator(
      onRefresh: () async {
        await widget.market!.lmsr.updateCurrentX();
        await widget.market!.lmsr.updateHistoricalX();
        await Future.delayed(Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10),
            PageHeader(
                p1,
                widget.market,
                InfoBox(title: 'Binary markets', pages: [
                  MiniInfoPage(
                      'A binary market has a payout of either £10 or £0, based on whether a team finishes higher or lower than a chosen league position.  Design your own binary market by dragging the cut-off in the payout graph.',
                      Transform.rotate(
                          angle: 3.14159 / 2, child: Icon(Icons.vertical_align_center, size: 80)),
                      Colors.blue[600]),
                  MiniInfoPage(
                      'Hit the lock switch to keep your selected payout structure in place. Once locked, touch each bar to view the exact payout. You can also tap the reverse icon to flip the directionality of the cut-off.',
                      Transform.scale(scale: 1.8, child: Switch(value: false, onChanged: (value) {},)),
                      Colors.grey[600]),
                  MiniInfoPage(
                      'You can also tap the reverse icon to flip the directionality of the cut-off.',
                      Icon(Icons.loop, size: 80),
                      Colors.grey[700]),
                ])),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    Text('Lock payout'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.loop),
                      onPressed: () {
                        setState(() {
                          reversed = !reversed;
                          p1 = p1!.map((i) => 10 - i).toList();
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text('Reverse'),
                    )
                  ],
                )
              ],
            ),
            locked
                ? TrueStaticPayoutGraph(p1, Colors.blue, lrPadding, graphHeight, true)
                : GestureDetector(
                    child: TrueStaticPayoutGraph(p1, Colors.blue, lrPadding, graphHeight, false),
                    onVerticalDragStart: (DragStartDetails details) {
                      _updateBars(details.localPosition);
                    },
                    onVerticalDragUpdate: (DragUpdateDetails details) {
                      _updateBars(details.localPosition);
                    },
                    onTapDown: (TapDownDetails details) {
                      _updateBars(details.localPosition);
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      _updateBars(details.localPosition);
                    },
                  ),
            SizedBox(height: 35),
            TabbedPriceGraph(priceHistory: priceHistory, times: widget.market!.lmsr.times),
            SizedBox(height: 20),
            Divider(thickness: 2),
            PageFooter(widget.market)
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
