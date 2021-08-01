import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';

import '../../data/objects/portfolios.dart';
import '../../utils/numerical/array_operations.dart';
import '../../utils/design/colors.dart';

double pi = 3.1415926535;

class SegmentData {
  final double? percentage;
  final Color? colour;

  SegmentData({this.percentage, this.colour});

  @override
  String toString() {
    return 'SegmentData(${this.percentage}, ${this.colour})';
  }
}

class MiniDonutChart extends StatelessWidget {
  final Portfolio portfolio;
  final double strokeWidth;

  MiniDonutChart(this.portfolio, {this.strokeWidth = 10});

  @override
  Widget build(BuildContext context) {
    SplayTreeMap<String, double> sortedValues = SplayTreeMap<String, double>.from(
        portfolio.currentValues, (a, b) => portfolio.currentValues[a]! < portfolio.currentValues[b]! ? 1 : -1);

    List<SegmentData> pieData = <SegmentData>[
          SegmentData(
            percentage: portfolio.cash / portfolio.currentValue,
            colour: Colors.green,
          )
        ] +
        range(sortedValues.length).map((int i) {
          Market market = portfolio.markets[sortedValues.keys.toList()[i]]!;
          return SegmentData(
              percentage: sortedValues.values.toList()[i] / portfolio.currentValue,
              colour: market.colours == null
                  ? getColorCycle(i, sortedValues.length)
                  : fromHex(market.colours![0]));
        }).toList();

    return CustomPaint(painter: MiniDonutChartPainter(pieData, strokeWidth));
  }
}

class MiniDonutChartPainter extends CustomPainter {
  final List<SegmentData> pieData;
  final double strokeWidth;
  double start = 0;
  double end = 0;

  MiniDonutChartPainter(this.pieData, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    for (SegmentData data in pieData) {
      Paint arcPaint = Paint()
        ..color = data.colour!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      end += data.percentage!;

      Path path = Path();
      double startAngle = 2 * pi * (this.start - 0.25);
      double endAngle = 2 * pi * (this.end - this.start);
      path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), startAngle, endAngle);
      start = end;
      canvas.drawPath(path, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
