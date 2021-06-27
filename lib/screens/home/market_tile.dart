import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../providers/settings_provider.dart';
import 'options/market_details.dart';
import '../../utils/strings/number_format.dart';
import '../../data/objects/markets.dart';


class MarketTile extends StatelessWidget {

  final Market? market;
  final double height;
  final double imageHeight;
  final EdgeInsets padding;

  final double upperTextSize = 16.0;
  final double lowerTextSize = 12.0;
  final double spacing = 3.0;

  MarketTile({
    required this.market,
    this.height = 115.0,
    this.imageHeight = 50.0,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
  });

  @override
  Widget build(BuildContext context) {


    return InkWell(
      onTap: () {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return MarketDetails(market);
    }));
  },
      child: Container(
        height: height,
        padding: padding,
        child: Row(children: [
          market!.imageURL != null
              ? Container(
                  height: imageHeight,
                  width: imageHeight,
                  child: CachedNetworkImage(
                    imageUrl: market!.imageURL!,
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
                          Text(market!.name!, style: TextStyle(fontSize: upperTextSize)),
                          SizedBox(height: spacing),
                          Text(
                            '${market!.info1} • ${market!.info2} • ${market!.info3}',
                            style: TextStyle(fontSize: lowerTextSize, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Consumer(
                        builder: (context, watch, value) {
                          String? currency = watch(settingsProvider).currency;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatCurrency(market!.currentBackValue, currency),
                                style: TextStyle(fontSize: upperTextSize),
                              ),
                              SizedBox(height: spacing),
                              Text(
                                  '${(market!.dailyBackValue!.last - market!.dailyBackValue!.first) < 0 ? '-' : '+'}${formatPercentage(((market!.dailyBackValue!.last - market!.dailyBackValue!.first) / market!.dailyBackValue!.first).abs(), currency)}  (${(market!.dailyBackValue!.last - market!.dailyBackValue!.first) < 0 ? '-' : '+'}${formatCurrency((market!.dailyBackValue!.last - market!.dailyBackValue!.first).abs(), currency)})',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: (market!.dailyBackValue!.last - market!.dailyBackValue!.first) >= 0 ? Colors.green[300] : Colors.red[300])),
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
                      child: CustomPaint(painter: MiniPriceChartPainter(market!.dailyBackValue)),
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
  List<double>? pathY;
  Color? lineColor;
  MiniPriceChartPainter(this.pathY) {
    if (this.pathY![0] > this.pathY![this.pathY!.length - 1])
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

    int N = pathY!.length;
    double pmin = pathY!.reduce(min);
    double pmax = pathY!.reduce(max);

    Path path = Path();

    if (pmin != pmax) {
      List pathpY = pathY!.map((y) => size.height * (1 - (y - pmin) / (pmax - pmin))).toList();
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
