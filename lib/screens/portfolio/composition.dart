import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';
import 'package:sportfolios_alpha/plots/donut_chart.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/screens/home/market_details.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

class Composition extends StatefulWidget {
  final Portfolio portfolio;
  Composition(this.portfolio);

  @override
  _CompositionState createState() => _CompositionState();
}

class _CompositionState extends State<Composition> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
              AnimatedDonutChart(widget.portfolio),
              Consumer(builder: (context, watch, child) {
                String asset = watch(selectedAssetProvider).asset;
                double pmax = 10;
                if (asset != null) {
                  pmax = getMax(widget.portfolio.currentQuantities[asset]);
                }

                return TweenAnimationBuilder(
                  curve: Curves.easeOutSine,
                  child: (asset == null || asset == 'cash')
                      ? null
                      : TrueStaticPayoutGraph(
                          widget.portfolio.currentQuantities[asset],
                          Colors.blue,
                          25,
                          200,
                          true,
                          pmax,
                        ),
                  duration: Duration(milliseconds: 250),
                  tween: Tween<double>(begin: 0, end: (asset == null || asset == 'cash') ? 0 : 240),
                  builder: (BuildContext context, double value, Widget child) {
                    return Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        height: value,
                        // color: Colors.green,
                        child: value == 240 ? child : null);
                  },
                  onEnd: () {},
                );
              }),
              SizedBox(height: 15)
            ] +
            range(2 * widget.portfolio.nCurrentMarkets).map((int i) {
              if (i % 2 == 0) {
                return Divider(
                  thickness: 2,
                );
              }

              String marketId = widget.portfolio.sortedValues.keys.toList()[(i / 2).floor()];
              return PortfolioComponentTile(
                  market: widget.portfolio.currentMarkets[marketId],
                  value: widget.portfolio.currentValues[marketId]);
            }).toList(),
      ),
    );
  }
}

class PortfolioComponentTile extends StatefulWidget {
  final Market market;
  final double height = 115.0;
  final double imageHeight = 50.0;
  final EdgeInsets padding = EdgeInsets.symmetric(vertical: 10, horizontal: 10);
  final double value;

  PortfolioComponentTile({
    @required this.market,
    @required this.value,
  });

  @override
  State<StatefulWidget> createState() {
    return PortfolioComponentTileState();
  }
}

class PortfolioComponentTileState extends State<PortfolioComponentTile> {
  final double upperTextSize = 16.0;
  final double lowerTextSize = 12.0;
  final double spacing = 3.0;

  PortfolioComponentTileState();

  void _goToMarketDetailsPage() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return MarketDetails(widget.market);
    }));
  }

  Widget _valueChangeText(String currency, double valueChange, double percentChange) {
    String sign = valueChange > 0 ? '+' : '-';
    return Text(
        '$sign${formatPercentage(percentChange.abs(), currency)}  ($sign${formatCurrency(valueChange.abs(), currency)})',
        style: TextStyle(fontSize: 12, color: valueChange > 0 ? Colors.green[300] : Colors.red[300]));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _goToMarketDetailsPage,
      child: Container(
        height: widget.height,
        padding: widget.padding,
        child: Row(children: [
          widget.market.imageURL != null
              ? Container(
                  height: widget.imageHeight,
                  width: widget.imageHeight,
                  child: CachedNetworkImage(
                    imageUrl: widget.market.imageURL,
                    height: widget.imageHeight,
                  ),
                )
              : (widget.market.id == 'cash'
                  ? Container(
                      height: widget.imageHeight,
                      width: 50,
                      child: Text(
                        '💸',
                        style: TextStyle(fontSize: 40),
                      ))
                  : Container(height: widget.imageHeight)),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.market.name, style: TextStyle(fontSize: upperTextSize)),
                          SizedBox(height: spacing),
                          widget.market.id == 'cash'
                              ? Container()
                              : Text(
                                  '${widget.market.info1} • ${widget.market.info2} • ${widget.market.info3}',
                                  style: TextStyle(fontSize: lowerTextSize, color: Colors.grey[600]),
                                ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(widget.value, 'GBP'),
                            style: TextStyle(fontSize: upperTextSize),
                          ),
                          SizedBox(height: spacing),
                          // _valueChangeText(
                          //     'GBP',
                          //     widget.market.dailyBackValue.values.last -
                          //         widget.market.dailyBackValue.values.first,
                          //     (widget.market.dailyBackValue.values.last -
                          //             widget.market.dailyBackValue.values.first) /
                          //         widget.market.dailyBackValue.values.first),
                        ],
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 5, left: 10, right: 10),
                      width: double.infinity,
                      // child: CustomPaint(painter: MiniPriceChartPainter(widget.market.dailyBackValue.values.toList())),
                    ),
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
