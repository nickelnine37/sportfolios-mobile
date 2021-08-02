import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportfolios_alpha/screens/home/app_bar.dart';
import 'package:sportfolios_alpha/utils/design/colors.dart';
import 'package:sportfolios_alpha/utils/numerical/arrays.dart';

import '../../data/objects/markets.dart';
import '../../data/objects/portfolios.dart';
import '../../plots/donut_chart.dart';
import '../../plots/payout_graph.dart';
import '../home/options/market_details.dart';
import 'sell.dart';
import '../../utils/numerical/array_operations.dart';
import '../../utils/strings/number_format.dart';

Widget getIcon(String type) {
  if (type == 'long') {
    return Row(children: [
      Text('Long', style: TextStyle(fontSize: 14.0, color: Colors.grey[700])),
      SizedBox(width: 5),
      Icon(Icons.trending_up, size: 20, color: Colors.green[600])
    ]);
  } else if (type == 'short') {
    return Row(children: [
      Text('Short', style: TextStyle(fontSize: 14.0, color: Colors.grey[700])),
      SizedBox(width: 5),
      Icon(Icons.trending_down, size: 20, color: Colors.red[600])
    ]);
  } else if (type == 'binary') {
    return Row(children: [
      Text('Binary', style: TextStyle(fontSize: 14.0, color: Colors.grey[700])),
      SizedBox(width: 5),
      Transform.rotate(angle: 3.14159 / 2, child: Icon(Icons.vertical_align_center, size: 20, color: Colors.blue[800])),
    ]);
  } else if (type == 'custom') {
    return Row(children: [
      Text('Custom', style: TextStyle(fontSize: 14.0, color: Colors.grey[700])),
      SizedBox(width: 5),
      Icon(Icons.bar_chart, size: 20, color: Colors.blue[800])
    ]);
  } else if (type == 'long/short') {
    return Row(children: [
      Text('Long/Short', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
      SizedBox(width: 5),
      Icon(Icons.shuffle, size: 20, color: Colors.blue[800])
    ]);
  } else {
    throw Exception();
  }
}

class Holdings extends StatefulWidget {
  final Portfolio? portfolio;
  final bool owner;

  Holdings({required this.portfolio, required this.owner});

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

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

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

  Future<void> fullRefresh() async {
    await widget.portfolio!.populateMarketsFirebase();
    await widget.portfolio!.populateMarketsServer();
    widget.portfolio!.getCurrentValue();
    widget.portfolio!.getHistoricalValue();
  }

  @override
  Widget build(BuildContext context) {
    if (isExpanded == null) {
      isExpanded = range(widget.portfolio!.markets.length).map((int i) => false).toList();
    }

    SplayTreeMap<String, double> sortedValues = SplayTreeMap<String, double>.from(
        widget.portfolio!.currentValues, (a, b) => widget.portfolio!.currentValues[a]! < widget.portfolio!.currentValues[b]! ? 1 : -1);

    return FutureBuilder(
        future: portfolioUpdateFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
              onRefresh: refreshHoldings,
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  Stack(
                    children: [
                      AnimatedDonutChart(widget.portfolio),
                      Container(
                        height: 286,
                        width: double.infinity,
                        child: Consumer(
                          builder: (BuildContext context, watch, Widget? child) {
                            String? asset = watch(selectedAssetProvider).asset;

                            return (asset == null || !widget.owner)
                                ? Container()
                                : Container(
                                    padding: EdgeInsets.all(15),
                                    child: IconButton(
                                      onPressed: () async {
                                        Color? color = await showDialog(
                                          context: context,
                                          builder: (context) => PickAColor(),
                                        );
                                        if (color != null) {
                                          await FirebaseFirestore.instance
                                              .collection('portfolios')
                                              .doc(widget.portfolio!.id)
                                              .update({'colours.${asset}': toHex(color)});
                                          setState(() {
                                            widget.portfolio!.colours[asset] = color;
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.format_color_fill),
                                      color: Colors.grey[700],
                                    ),
                                    alignment: Alignment.bottomRight,
                                  );
                          },
                        ),
                      )
                    ],
                  ),
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
                              setState(() {
                                isExpanded![i] = !itemIsExpanded;
                              });
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
                                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                                                          getIcon(classify(holding))
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
                                                      widget.owner
                                                          ? OutlinedButton(
                                                              onPressed: () async {
                                                                bool saleComplete = await showModalBottomSheet(
                                                                      isScrollControlled: true,
                                                                      elevation: 100,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                                                                      context: context,
                                                                      builder: (context) {
                                                                        return SellMarket(widget.portfolio, market,
                                                                            widget.portfolio!.holdings[marketId]!);
                                                                      },
                                                                    ) ??
                                                                    false;

                                                                if (saleComplete) {
                                                                  setState(() {
                                                                    portfolioUpdateFuture = fullRefresh();
                                                                  });
                                                                }
                                                              },
                                                              // style: TextButton.styleFrom(backgroundColor: Colors.red[400]),
                                                              child: Text('SELL',
                                                                  style: TextStyle(color: Colors.grey[800], letterSpacing: 0.6)),
                                                            )
                                                          : Container(),
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: LeagueProgressBar(leagueOrMarket: market, textColor: Colors.grey[800]!),
                                  ), 
                                  SizedBox(height: 4), 
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

class PickAColor extends StatefulWidget {
  const PickAColor({Key? key}) : super(key: key);

  @override
  _PickAColorState createState() => _PickAColorState();
}

class _PickAColorState extends State<PickAColor> {
  Color color = Colors.red;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: color,
          onColorChanged: (Color selectedColor) {
            color = selectedColor;
          },
          showLabel: true,
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Got it'),
          onPressed: () {
            Navigator.of(context).pop(color);
          },
        ),
      ],
    );
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
