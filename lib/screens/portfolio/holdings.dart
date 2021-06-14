import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';
import 'package:sportfolios_alpha/plots/donut_chart.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/screens/home/market_details.dart';
import 'package:sportfolios_alpha/screens/portfolio/sell.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';
import 'package:sportfolios_alpha/utils/strings/number_format.dart';

class Holdings extends StatefulWidget {
  final Portfolio portfolio;
  Holdings(this.portfolio);

  @override
  _HoldingsState createState() => _HoldingsState();
}

class _HoldingsState extends State<Holdings> {
  String currentPortfolioId;
  double op = 0;
  String selectedAsset;
  List<bool> isExpanded;
  final double imageHeight = 50;
  Future<void> portfolioUpdateFuture;

  @override
  void initState() {
    super.initState();
    portfolioUpdateFuture = Future.delayed(Duration(seconds: 0));
  }

  @override
  Widget build(BuildContext context) {
    if (isExpanded == null) {
      isExpanded = range(widget.portfolio.nCurrentMarkets).map((int i) => false).toList();
    }

    return FutureBuilder(
        future: portfolioUpdateFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(children: <Widget>[
                AnimatedDonutChart(widget.portfolio),
                SizedBox(height: 15),
                // PortfolioItems(widget.portfolio),
                ExpansionPanelList(
                  elevation: 2,
                  animationDuration: Duration(milliseconds: 600),
                  expansionCallback: (int i, bool itemIsExpanded) {
                    if (widget.portfolio.sortedValues.keys.toList()[i] != 'cash') {
                      setState(() {
                        isExpanded[i] = !itemIsExpanded;
                      });
                    }
                  },
                  children: range(widget.portfolio.nCurrentMarkets).map<ExpansionPanel>((int i) {
                    //
                    String marketId = widget.portfolio.sortedValues.keys.toList()[i];
                    Market market = widget.portfolio.markets[marketId];
                    List<double> quantity = widget.portfolio.currentQuantities[marketId];
                    double value = widget.portfolio.currentValues[marketId];
                    double pmax = getMax(quantity);
                    List<double> dailyPriceChart = market.lmsr.getHistoricalValue(quantity)['d'];
                    double valueChange = dailyPriceChart.last - dailyPriceChart.first;
                    double percentChange = valueChange / dailyPriceChart.first;
                    String sign = valueChange < 0 ? '-' : '+';

                    return ExpansionPanel(
                      headerBuilder: (BuildContext context, bool itemIsExpanded) {
                        return ListTile(
                          onTap: () {
                            if (marketId != 'cash') {
                              Navigator.of(context)
                                  .push(MaterialPageRoute<void>(builder: (BuildContext context) {
                                return MarketDetails(market);
                              }));
                            }
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
                                                        imageUrl: market.imageURL,
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
                                                  Text(market.name, style: TextStyle(fontSize: 16)),
                                                  SizedBox(height: 3),
                                                  marketId == 'cash'
                                                      ? Container()
                                                      : Text(
                                                          '${sign}${formatPercentage(percentChange.abs(), 'GBP')}  (${sign}${formatCurrency(valueChange.abs(), 'GBP')})',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: valueChange >= 0
                                                                  ? Colors.green[300]
                                                                  : Colors.red[300]),
                                                        ),
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
                                  child: TrueStaticPayoutGraph(
                                    quantity,
                                    Colors.blue,
                                    25,
                                    150,
                                    true,
                                    pmax,
                                  ),
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
                                          return SellMarket(widget.portfolio, market, quantity);
                                        },
                                      );

                                      if (saleComplete) {
                                        setState(() {
                                          portfolioUpdateFuture = widget.portfolio.updateQuantities();
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
                      isExpanded: isExpanded[i],
                    );
                  }).toList(),
                )
              ]),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
