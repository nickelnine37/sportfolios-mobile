import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/numerical/arrays.dart';

import 'options/market_details.dart';
import '../../utils/strings/number_format.dart';
import '../../data/objects/markets.dart';

class MarketTile extends StatelessWidget {
  final Market market;
  final double height;
  final double imageHeight;
  final EdgeInsets padding;
  final String? returnsPeriod;

  final double upperTextSize = 16.0;
  final double lowerTextSize = 12.0;
  final double spacing = 3.0;

  MarketTile({
    required this.market,
    required this.returnsPeriod,
    this.height = 115.0,
    this.imageHeight = 50.0,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
          if (market.runtimeType == TeamMarket) {
            return TeamDetails(market);
          } else {
            return PlayerDetails(market);
          }
        }));
      },
      child: Container(
        height: height,
        padding: padding,
        child: Row(children: [
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
                          Text(market.name!, style: TextStyle(fontSize: upperTextSize)),
                          SizedBox(height: spacing),
                          Text(
                            '${market.info1} • ${market.info2} • ${market.info3}',
                            style: TextStyle(fontSize: lowerTextSize, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(market.longPriceCurrent, 'GBP'),
                            style: TextStyle(fontSize: upperTextSize),
                          ),
                          SizedBox(height: spacing),
                          Text(
                              '${market.longPriceReturnsHist![returnsPeriod]! < 0 ? '-' : '+'}${formatPercentage((market.longPriceReturnsHist![returnsPeriod]!).abs(), 'GBP')}  (${market.longPriceReturnsHist![returnsPeriod]! < 0 ? '-' : '+'}${formatCurrency((market.longPriceHist![returnsPeriod]!.last - market.longPriceHist![returnsPeriod]!.first).abs(), 'GBP')})',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: (market.longPriceReturnsHist![returnsPeriod]!) >= 0 ? Colors.green[300] : Colors.red[300])),
                        ],
                      )
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
                      width: double.infinity,
                      child: CustomPaint(painter: MiniPriceChartPainter(pathY: market.longPriceHist![returnsPeriod]!)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(<String, String>{'d': '-24h', 'w': '-1w', 'm': '-1mth', 'M': 'start'}[returnsPeriod]!,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      Text('now', style: TextStyle(fontSize: 11, color: Colors.grey[500]))
                    ],
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
  Array pathY;
  Color? lineColor;
  MiniPriceChartPainter({required this.pathY}) {
    if (this.pathY[0] > this.pathY[this.pathY.length - 1])
      this.lineColor = Colors.red[300];
    else
      this.lineColor = Colors.green[300];
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = lineColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    int N = pathY.length;
    double pmin = pathY.min;
    double pmax = pathY.max;

    Path path = Path();

    if (pmin != pmax) {
      Array pathpY = pathY.apply((y) => 0.95 * size.height * (1 - (y - pmin) / (pmax - pmin)));
      List pathpX = List.generate(N, (index) => index * size.width / (N - 1));

      path.moveTo(pathpX[0], pathpY[0]);
      for (int i = 0; i < N; i++) {
        if (i % 2 == 0) {
          path.lineTo(pathpX[i], pathpY[i]);
        }
      }
      path.lineTo(pathpX.last, pathpY.last);
    } else {
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
    }

    canvas.drawPath(path, paint);

    Rect rect = Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height));
    LinearGradient lg = LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, stops: [
      0.0,
      0.6,
      1.0
    ], colors: [
      //create 2 white colors, one transparent
      Color.fromARGB(0, 250, 250, 250),
      Color.fromARGB(0, 250, 250, 250),
      Color.fromARGB(240, 250, 250, 250)
    ]);
    Paint paint2 = Paint()..shader = lg.createShader(rect);
    canvas.drawRect(rect, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
