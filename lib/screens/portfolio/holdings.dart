import 'dart:collection';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/numerical/arrays.dart';

import '../../data/objects/markets.dart';
import '../../data/objects/portfolios.dart';
import '../../plots/donut_chart.dart';
import '../../plots/payout_graph.dart';
import '../home/options/market_details.dart';
import 'sell.dart';
import '../../utils/numerical/array_operations.dart';
import '../../utils/strings/number_format.dart';

class Holdings extends StatefulWidget {
  final Portfolio? portfolio;
  Holdings(this.portfolio);

  @override
  _HoldingsState createState() => _HoldingsState();
}

class _HoldingsState extends State<Holdings> {
  String? currentPortfolioId;
  double op = 0;
  String? selectedAsset;
  List<bool>? isExpanded;
  final double imageHeight = 50;
  Future<void>? portfolioUpdateFuture;

  @override
  void initState() {
    super.initState();
    portfolioUpdateFuture = Future.delayed(Duration(seconds: 0));
  }

  Future<void> refreshHoldings() async {
    await widget.portfolio!.getCurrentValue();
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isExpanded == null) {
      isExpanded = range(widget.portfolio!.markets.length).map((int i) => false).toList();
    }

    SplayTreeMap<String, double> sortedValues = SplayTreeMap<String, double>.from(
        widget.portfolio!.currentValues, (a, b) => widget.portfolio!.currentValues[a]! < widget.portfolio!.currentValues[b]! ? 1 : -1);

    Map<String, Row> icons = {
      'long': Row(children: [
        Text('Long', style: TextStyle(fontSize: 14.0, color: Colors.grey[700])),
        SizedBox(width: 3),
        Icon(Icons.trending_up, size: 20, color: Colors.green[600])
      ]),
      'short': Row(children: [
        Text('Short', style: TextStyle(fontSize: 14.0, color: Colors.grey[700])),
        SizedBox(width: 3),
        Icon(Icons.trending_down, size: 20, color: Colors.red[600])
      ]),
      'binary': Row(children: [
        Text('Binary', style: TextStyle(fontSize: 14.0, color: Colors.grey[700])),
        SizedBox(width: 3),
        Transform.rotate(angle: 3.14159 / 2, child: Icon(Icons.vertical_align_center, size: 20, color: Colors.blue[800])),
      ]),
      'custom': Row(children: [
        Text('Custom', style: TextStyle(fontSize: 14.0, color: Colors.grey[700])),
        SizedBox(width: 3),
        Icon(Icons.bar_chart, size: 20, color: Colors.blue[800])
      ]),
      'long/short': Row(children: [
        Text('Long/Short', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
        SizedBox(width: 3),
        Icon(Icons.shuffle, size: 20, color: Colors.blue[800])
      ]),
    };

    return FutureBuilder(
        future: portfolioUpdateFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
              onRefresh: refreshHoldings,
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  AnimatedDonutChart(widget.portfolio),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 55.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('Cash', style: TextStyle(fontSize: 19, color: Colors.grey[800], fontWeight: FontWeight.w400)),
                            Text(formatCurrency(widget.portfolio!.cash, 'GBP'),
                                style: TextStyle(fontSize: 17, color: Colors.grey[800], fontWeight: FontWeight.w400))
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Assets',
                              style: TextStyle(fontSize: 19, color: Colors.grey[800], fontWeight: FontWeight.w400),
                            ),
                            Text(
                              formatCurrency(widget.portfolio!.currentValue - widget.portfolio!.cash, 'GBP'),
                              style: TextStyle(fontSize: 17, color: Colors.grey[800], fontWeight: FontWeight.w400),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    'Holdings',
                    style: TextStyle(fontSize: 19, color: Colors.grey[800], fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 15),
                  widget.portfolio!.currentValues.length == 0
                      ? Text(
                          '  Nothing to see here yet...',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[800]),
                        )
                      : ExpansionPanelList(
                          elevation: 2,
                          animationDuration: Duration(milliseconds: 600),
                          expansionCallback: (int i, bool itemIsExpanded) {
                            if (widget.portfolio!.currentValues.keys.toList()[i] != 'cash') {
                              setState(() {
                                isExpanded![i] = !itemIsExpanded;
                              });
                            }
                          },
                          children: range(sortedValues.length).map<ExpansionPanel>((int i) {
                            //
                            String marketId = sortedValues.keys.toList()[i];
                            Market market = widget.portfolio!.markets[marketId]!;
                            Array holding = widget.portfolio!.holdings[marketId]!;
                            double value = -market.currentLMSR!.priceTrade(holding.scale(-1));

                            return ExpansionPanel(
                              headerBuilder: (BuildContext context, bool itemIsExpanded) {
                                return ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
                                      if (market.runtimeType == TeamMarket) {
                                        return TeamDetails(market);
                                      } else {
                                        return PlayerDetails(market);
                                      }
                                    }));
                                  },
                                  title: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      market.imageURL != null
                                                          ? Container(
                                                              height: imageHeight,
                                                              width: imageHeight,
                                                              child: CachedNetworkImage(
                                                                imageUrl: market.imageURL!,
                                                                height: imageHeight,
                                                              ),
                                                            )
                                                          : Container(height: imageHeight),
                                                      SizedBox(width: 15),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(market.name!, style: TextStyle(fontSize: 16, color: Colors.grey[850])),
                                                          SizedBox(height: 3),
                                                          icons[classify(holding)]!
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        formatCurrency(value, 'GBP'),
                                                        style: TextStyle(fontSize: 16, color: Colors.grey[850]),
                                                      ),
                                                      // SizedBox(height: 5),
                                                      // SizedBox(
                                                      // height: 30,
                                                      // width: 65,
                                                      OutlinedButton(
                                                        onPressed: () async {
                                                          bool saleComplete = await showModalBottomSheet(
                                                                isScrollControlled: true,
                                                                elevation: 100,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                                                                context: context,
                                                                builder: (context) {
                                                                  return SellMarket(
                                                                      widget.portfolio, market, widget.portfolio!.holdings[marketId]!);
                                                                },
                                                              ) ??
                                                              false;

                                                          if (saleComplete) {
                                                            setState(() {
                                                              // portfolioUpdateFuture = widget.portfolio!.updateQuantities();
                                                            });
                                                          }
                                                        },
                                                        // style: TextButton.styleFrom(backgroundColor: Colors.red[400]),
                                                        child: Text('SELL', style: TextStyle(color: Colors.grey[800], letterSpacing: 0.6)),
                                                      ),
                                                      // )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              body: Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  marketId.contains('T')
                                      ? Container(
                                          height: 220,
                                          // color: Colors.grey[500],
                                          // padding: const EdgeInsets.only(bottom: 20),
                                          child: PayoutGraph(
                                            q: holding,
                                            tappable: true,
                                            pmax: holding.max,
                                          ),
                                        )
                                      : Container(
                                          height: 150,
                                          child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 25),
                                              child: LongShortGraph(quantity: holding, height: 75)),
                                        ),
                                ],
                              ),
                              isExpanded: isExpanded![i],
                            );
                          }).toList(),
                        )
                ]),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

class LongShortGraph extends StatelessWidget {
  final Array quantity;
  final double height;

  LongShortGraph({required this.quantity, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: LongShortGraphPainter(quantity)),
    );
  }
}

class LongShortGraphPainter extends CustomPainter {
  final Array quantity;

  LongShortGraphPainter(this.quantity);

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter longPainter = TextPainter(
        text: TextSpan(
          text: 'Units Long\n${quantity[0]}',
          style: TextStyle(color: Colors.grey[850], fontSize: 13, fontWeight: FontWeight.w400),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);

    TextPainter shortPainter = TextPainter(
        text: TextSpan(
          text: 'Units Short\n${quantity[1]}',
          style: TextStyle(color: Colors.grey[850], fontSize: 13, fontWeight: FontWeight.w400),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);

    longPainter.layout(minWidth: 0, maxWidth: 100);
    shortPainter.layout(minWidth: 0, maxWidth: 100);

    double p0 = shortPainter.width + 15;

    Rect rect1 = Rect.fromPoints(
      Offset(p0, 2 * size.height / 7),
      Offset((size.width - p0) * quantity[0] / quantity.max + p0, size.height / 7),
    );
    Rect rect2 = Rect.fromPoints(
      Offset(shortPainter.width + 15, 4 * size.height / 7),
      Offset((size.width - p0) * quantity[1] / quantity.max + p0, 3 * size.height / 7),
    );

    Paint paint1 = Paint()..color = Colors.green[500]!;
    Paint paint2 = Paint()..color = Colors.red[500]!;

    canvas.drawRect(rect1, paint1);
    canvas.drawRect(rect2, paint2);
    longPainter.paint(canvas, Offset(0, 3.5 * size.height / 28));
    shortPainter.paint(canvas, Offset(0, 11.5 * size.height / 28));

    Path touchLine = Path();

    touchLine.moveTo(p0, 0);
    touchLine.lineTo(p0, 5 * size.height / 7);
    

    Paint touchLinePaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(touchLine, touchLinePaint);


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
