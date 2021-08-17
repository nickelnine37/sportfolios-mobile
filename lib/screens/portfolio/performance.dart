import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/screens/home/options/market_details.dart';
import 'package:sportfolios_alpha/screens/portfolio/holdings.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';
import 'package:intl/intl.dart';
import 'package:sportfolios_alpha/utils/strings/number_format.dart';

import '../../data/objects/portfolios.dart';
import '../../plots/price_chart.dart';

class Performance extends StatefulWidget {
  final Portfolio? portfolio;
  Performance(this.portfolio);
  @override
  _PerformanceState createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  List<bool>? isExpanded;
  final double imageHeight = 40;

  @override
  Widget build(BuildContext context) {
    if (isExpanded == null || isExpanded!.length != widget.portfolio!.transactions.length) {
      isExpanded = range(widget.portfolio!.transactions.length).map((int i) => false).toList();
    }

    return SingleChildScrollView(
      child: Column(children: [
        // SizedBox(height: 10),
        // Text(
        //   'Portfolio performance',
        //   style: TextStyle(fontSize: 19, color: Colors.grey[700], fontWeight: FontWeight.w400),
        // ),
        TabbedPriceGraph(
          priceHistory: widget.portfolio!.historicalValue,
          times: widget.portfolio!.times,
        ),
        SizedBox(height: 35),
        Text(
          'Transaction History',
          style: TextStyle(fontSize: 19, color: Colors.grey[700], fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 15),
        widget.portfolio!.transactions.length == 0
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
                children: range(widget.portfolio!.transactions.length).map<ExpansionPanel>((int i) {
                  //
                  String marketId = widget.portfolio!.transactions.map((Transaction trans) => trans.market.id).toList()[i];
                  Market market = widget.portfolio!.transactions.map((Transaction trans) => trans.market).toList()[i];
                  Transaction transaction = widget.portfolio!.transactions[i];

                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool itemIsExpanded) {
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
                            if (market.runtimeType == TeamMarket) {
                              return TeamDetails(market, null);
                            } else {
                              return PlayerDetails(market, null);
                            }
                          }));
                        },
                        title: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
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
                                                Text(
                                                    DateFormat('d MMM yy HH:mm')
                                                        .format(DateTime.fromMillisecondsSinceEpoch((transaction.time * 1000).floor())),
                                                    style: TextStyle(fontSize: 16)),
                                                SizedBox(height: 3),
                                                Text(
                                                  market.name!,
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
                                        transaction.price > 0
                                            ? Text(
                                                'BUY',
                                                style: TextStyle(fontSize: 16, color: Colors.green[600]),
                                              )
                                            : Text(
                                                'SELL',
                                                style: TextStyle(fontSize: 16, color: Colors.red[600]),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Text(transaction.price > 0 ? 'Bought for ${formatCurrency(transaction.price, 'GBP')}: ' : 'Sold for ${formatCurrency(-transaction.price, 'GBP')}: ',
                                style: TextStyle(fontSize: 16, color: Colors.grey[800]))),
                                SizedBox(height: 10), 
                        marketId.contains('T')
                            ? Container(
                                height: 250,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                width: double.infinity,
                                child: PayoutGraph(
                                  q: transaction.price > 0 ? transaction.quantity : transaction.quantity.scale(-1.0).add(1e-10),
                                  tappable: true,
                                  pmax: max(transaction.quantity.max.abs(), transaction.quantity.min.abs()),
                                ),
                              )
                            : Container(
                                height: 150,
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: LongShortGraph(
                                      quantity: transaction.price > 0 ? transaction.quantity : transaction.quantity.scale(-1.0).add(1e-10),
                                      height: 75),
                                ),
                              ),
                      ],
                    ),
                    isExpanded: isExpanded![i],
                  );
                }).toList(),
              )
      ]),
    );
    // return Container();
  }
}
