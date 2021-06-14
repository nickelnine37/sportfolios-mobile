import 'package:cached_network_image/cached_network_image.dart';
import 'package:sportfolios_alpha/data/objects/leagues.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/screens/home/market_details.dart';
import 'package:sportfolios_alpha/utils/strings/number_format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';

class MarketTile extends StatefulWidget {
  final Market market;
  final League league;
  final double height;
  final double imageHeight;
  final EdgeInsets padding;

  MarketTile({
    @required this.market,
    @required this.league,
    this.height = 115.0,
    this.imageHeight = 50.0,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
  });

  @override
  State<StatefulWidget> createState() {
    return MarketTileState();
  }
}

class MarketTileState extends State<MarketTile> {
  final double upperTextSize = 16.0;
  final double lowerTextSize = 12.0;
  final double spacing = 3.0;
  double valueChange;
  double percentChange;
  String sign;

  MarketTileState();

  void _goToMarketDetailsPage() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return MarketDetails(widget.market);
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (valueChange == null) {
      valueChange = widget.market.dailyBackValue.last - widget.market.dailyBackValue.first;
      percentChange = valueChange / widget.market.dailyBackValue.first;
      sign = valueChange < 0 ? '-' : '+';
    }

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
              : Container(height: widget.imageHeight),
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
                          Text(
                            '${widget.market.info1} • ${widget.market.info2} • ${widget.market.info3}',
                            style: TextStyle(fontSize: lowerTextSize, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Consumer(
                        builder: (context, watch, value) {
                          String currency = watch(settingsProvider).currency;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatCurrency(widget.market.currentBackValue, currency),
                                style: TextStyle(fontSize: upperTextSize),
                              ),
                              SizedBox(height: spacing),
                              Text(
                                  '${sign}${formatPercentage(percentChange.abs(), currency)}  (${sign}${formatCurrency(valueChange.abs(), currency)})',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: valueChange >= 0 ? Colors.green[300] : Colors.red[300])),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
                      width: double.infinity,
                      child: CustomPaint(painter: MiniPriceChartPainter(widget.market.dailyBackValue)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('-24h', style: TextStyle(fontSize: 11, color: Colors.grey[500])), 
                    Text('now', style: TextStyle(fontSize: 11, color: Colors.grey[500]))],
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

class MiniPriceChartPainter extends CustomPainter {
  List<double> pathY;
  Color lineColor;
  MiniPriceChartPainter(this.pathY) {
    if (this.pathY[0] > this.pathY[this.pathY.length - 1])
      this.lineColor = Colors.red[300];
    else
      this.lineColor = Colors.green[300];
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    int N = pathY.length;
    double pmin = pathY.reduce(min);
    double pmax = pathY.reduce(max);

    Path path = Path();

    if (pmin != pmax) {
      List pathpY = pathY.map((y) => size.height * (1 - (y - pmin) / (pmax - pmin))).toList();
      List pathpX = List.generate(N, (index) => index * size.width / (N - 1));

      path.moveTo(pathpX[0], pathpY[0]);
      for (int i = 0; i < N; i++) {
        if (i % 3 == 0) {
          path.lineTo(pathpX[i], pathpY[i]);
        }
      }
      path.lineTo(pathpX.last, pathpY.last);
    } else {
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
