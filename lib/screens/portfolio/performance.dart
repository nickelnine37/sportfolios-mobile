import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';
import 'package:sportfolios_alpha/screens/home/options/market_details.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';
import 'package:intl/intl.dart';

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
    if (isExpanded == null) {
      isExpanded = range(widget.portfolio!.transactions.length).map((int i) => false).toList();
    }

    return SingleChildScrollView(
      child: Column(children: [
        TabbedPriceGraph(
          priceHistory: widget.portfolio!.historicalValue,
          times: widget.portfolio!.times,
        ),
        SizedBox(height: 35),
        Text(
          'Transaction History',
          style: TextStyle(fontSize: 19, color: Colors.grey[800], fontWeight: FontWeight.w400),
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
                  if (widget.portfolio!.currentValues.keys.toList()[i] != 'cash') {
                    setState(() {
                      isExpanded![i] = !itemIsExpanded;
                    });
                  }
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
                              return TeamDetails(market);
                            } else {
                              return PlayerDetails(market);
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
                    body: marketId == 'cash'
                        ? Container()
                        : Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              marketId.contains('T')
                                  ? Container(
                                      height: 250,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      // child: PayoutGraph(
                                      //   q: widget.portfolio!.holdings![marketId]!.q!,
                                      //   tappable: true,
                                      //   pmax: widget.portfolio!.holdings![marketId]!.q!.max,
                                      // ),
                                    )
                                  : Container(
                                      height: 150,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 25),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              // widget.portfolio!.holdings![marketId]!.k!
                                              children: [Text('Units Long', style: TextStyle(fontSize: 18)), Text('0')],
                                            ),
                                            Column(
                                              children: [Text('Units Short', style: TextStyle(fontSize: 18)), Text('0')],
                                            )
                                          ],
                                        ),
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
