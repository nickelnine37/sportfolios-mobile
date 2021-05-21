import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';
import 'package:sportfolios_alpha/screens/home/options/info_box.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';

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
  int selectedBar;
  double graphWidth;
  double graphHeight = 150;
  bool locked = false;

  @override
  void initState() {
    p1 = range(widget.market.n).map((int i) => 10.0).toList();
    p2 = range(widget.market.n).map((int i) => 10.0).toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void updateHistory() {
    priceHistory = widget.market.getHistoricalValue(p1);
  }

  void _makeSelection(Offset touchLocation) {
    int x = (widget.market.n * touchLocation.dx / graphWidth).floor();
    if (x < 0) {
      x = 0;
    } else if (x > widget.market.n - 1) {
      x = widget.market.n;
    }
    double y = 10 * (1 - (touchLocation.dy - 20) / (graphHeight + 20));

    if (y < 0) {
      y = 0;
    }
    if (y > 10) {
      y = 10;
    }
    p2 = range(widget.market.n).map((int i) => i == x ? y : p2[i]).toList();

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
                      Transform.scale(scale: 1.8, child: Switch(value: false, onChanged: (value) {},)),
                      Colors.grey[600]),
                  MiniInfoPage(
                      'You can also tap the reverse icon to flip the directionality of the cut-off.',
                      Icon(Icons.loop, size: 80),
                      Colors.grey[700]),
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
                ? TrueStaticPayoutGraph(p1, Colors.blue, lrPadding, graphHeight, true)
                : GestureDetector(
                    child: TrueStaticPayoutGraph(p1, Colors.blue, lrPadding, graphHeight, false),
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
            TabbedPriceGraph(priceHistory: priceHistory),
            SizedBox(height: 20),
            Divider(thickness: 2),
            Container(
              height: 60,
              child: Center(
                child: ListTile(
                  onTap: () {},
                  leading: Text(
                    'Portfolios',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  trailing: Icon(Icons.arrow_right, size: 28),
                ),
              ),
            ),
            Divider(thickness: 2),
            Container(
              height: 60,
              child: Center(
                child: ListTile(
                  onTap: () {},
                  leading: Text(
                    'Statistics',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  trailing: Icon(Icons.arrow_right, size: 28),
                ),
              ),
            ),
            Divider(thickness: 2),
            Container(
              height: 60,
              child: Center(
                child: ListTile(
                  onTap: () {},
                  leading: Text(
                    'Players',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  trailing: Icon(Icons.arrow_right, size: 28),
                ),
              ),
            ),
            Divider(thickness: 2),
          ],
        ),
      ),
    );
  }
}
