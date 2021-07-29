import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
                              formatCurrency(widget.portfolio!.currentValue! - widget.portfolio!.cash!, 'GBP'),
                              style: TextStyle(fontSize: 17, color: Colors.grey[800], fontWeight: FontWeight.w400),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25
                  ),
                  Text(
                    'Holdings',
                    style: TextStyle(fontSize: 19, color: Colors.grey[800], fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 15
                  ),
                  widget.portfolio!.currentValues.length == 0
                      ? Text('  Nothing to see here yet...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[800]),)
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
                            // List<double> quantity = widget.portfolio!.currentQuantities[marketId]!;
                            double? value = sortedValues.values.toList()[i];
                            // double? pmax = getMax(quantity);
                            // List<double>? dailyPriceChart = market.lmsr.getHistoricalValue(quantity)?['d']!;

                            // if (dailyPriceChart == null) {
                            //   dailyPriceChart = List<double>.generate(60, (index) => 1.0);
                            // }

                            // double valueChange = dailyPriceChart.last - dailyPriceChart.first;
                            // double percentChange = valueChange / dailyPriceChart.first;
                            // String sign = valueChange < 0 ? '-' : '+';

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
                                    padding: const EdgeInsets.symmetric(vertical: 25),
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
                                                          : (market.id == 'cash'
                                                              ? Container(
                                                                  height: imageHeight,
                                                                  width: 50,
                                                                  child: Text(
                                                                    '💸',
                                                                    style: TextStyle(fontSize: 40),
                                                                  ))
                                                              : Container(height: imageHeight)),
                                                      SizedBox(width: 15),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(market.name!, style: TextStyle(fontSize: 16)),
                                                          SizedBox(height: 3),
                                                          marketId == 'cash'
                                                              ? Container()
                                                              : Text(
                                                                  'Hey',
                                                                  // '${sign}${formatPercentage(percentChange.abs(), 'GBP')}  (${sign}${formatCurrency(valueChange.abs(), 'GBP')})',
                                                                  style: TextStyle(
                                                                    fontSize: 13,
                                                                    // color: valueChange >= 0 ? Colors.green[300] : Colors.red[300]),
                                                                  ),
                                                                )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    formatCurrency(value, 'GBP'),
                                                    style: TextStyle(fontSize: 16),
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
                              body: marketId == 'cash'
                                  ? Container()
                                  : Column(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 250,
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          // child: TrueStaticPayoutGraph(
                                          //   quantity,
                                          //   Colors.blue,
                                          //   25,
                                          //   150,
                                          //   true,
                                          //   pmax,
                                          // ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 15.0),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              bool saleComplete = await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    elevation: 100,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                                                    context: context,
                                                    builder: (context) {
                                                      return SellMarket(
                                                          widget.portfolio, market, widget.portfolio!.holdings![marketId]!.q!);
                                                    },
                                                  ) ??
                                                  false;

                                              if (saleComplete) {
                                                setState(() {
                                                  // portfolioUpdateFuture = widget.portfolio!.updateQuantities();
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.red[400],
                                                minimumSize: Size(120, 40),
                                                shape: new RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                )),
                                            child: Text('SELL', style: TextStyle(color: Colors.white)),
                                          ),
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
