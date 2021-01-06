import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:sportfolios_alpha/utils/axis_range.dart';

Widget tabSection(BuildContext context) {
  List<double> p1 = [
    14.0,
    11.7,
    10.86,
    10.12,
    11.11,
    11.39,
    12.3,
    12.2,
    11.65,
    12.75,
    13.17,
    13.45,
    15.45,
    16.34,
    15.01,
    14.81,
    14.54,
    16.21,
    17.72,
    17.54,
    17.67,
    16.57,
    16.35,
    16.81,
    16.38,
  ];

  return DefaultTabController(
    length: 4,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          //Add this to give height
          height: 200,
          child: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
            Container(
              height: 200,
              width: 200,
              child: Center(child: PriceGraph(prices: p1)),
            ),
            Container(
              child: Center(child: PriceGraph(prices: p1)),
            ),
            Container(
              child: Center(child: PriceGraph(prices: p1)),
            ),
            Container(
              child: Center(child: PriceGraph(prices: p1)),
            ),
          ]),
        ),
        Container(
          width: 250,
          height: 30,
          child: TabBar(indicatorSize: TabBarIndicatorSize.label, tabs: [
            Tab(text: "1d"),
            Tab(text: "1w"),
            Tab(text: "1m"),
            Tab(text: 'max'),
          ]),
        ),
      ],
    ),
  );
}

class PriceGraph extends StatelessWidget {
  final List<double> prices;
  PriceGraph({this.prices});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(250, 200),
      painter: MiniPriceChartPainter(prices),
    );
  }
}

class MiniPriceChartPainter extends CustomPainter {
  List<double> prices;

  MiniPriceChartPainter(this.prices);

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Paint shadePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..strokeWidth = 0
      ..shader = ui.Gradient.linear(
        Offset(100, 0),
        Offset(100, 200),
        [
          Colors.green[800],
          Colors.green[800].withOpacity(0),
        ],
      );

    Paint axisPaint = Paint()..color = Colors.grey[850] .. style = PaintingStyle.stroke .. strokeWidth = 2;

    int N = prices.length;
    double pmin = prices.reduce(min);
    double pmax = prices.reduce(max);

    List ticks = getAxisTicks(pmin, pmax);
    pmin = ticks[0];
    pmax = ticks[ticks.length - 1];

    List pathpY = prices
            .map((y) => size.height * (1 - (y - pmin) / (pmax - pmin)))
            .toList() +
        [
          size.height,
          size.height,
          size.height * (1 - (prices[0] - pmin) / (pmax - pmin)),
        ];
    List pathpX = List.generate(N, (index) => index * size.width / (N - 1)) +
        [size.width, 0, 0];

    Path line = Path();
    Path shading = Path();
    Path yaxis = Path();

    line.moveTo(pathpX[0], pathpY[0]);
    shading.moveTo(pathpX[0], pathpY[0]);

    for (int i = 0; i < N + 3; i++) {
      if (i < N) {
        line.lineTo(pathpX[i], pathpY[i]);
      }
      shading.lineTo(pathpX[i], pathpY[i]);
    }

    yaxis.moveTo(0, pmin);
    yaxis.moveTo(0, pmax);

    canvas.drawPath(line, linePaint);
    canvas.drawPath(shading, shadePaint);
    canvas.drawPath(yaxis, axisPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
