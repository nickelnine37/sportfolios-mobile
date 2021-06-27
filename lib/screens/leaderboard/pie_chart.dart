import 'package:flutter/material.dart';

import '../../data/objects/portfolios.dart';
import '../../utils/numerical/array_operations.dart';
import '../../utils/design/colors.dart';

double pi = 3.1415926535;

class SegmentData {
  final double percentage;
  final Color colour;

  SegmentData({this.percentage, this.colour});

  @override
  String toString() {
  return 'SegmentData(${this.percentage}, ${this.colour})';
   }

}

class MiniDonutChart extends StatelessWidget {
  final Portfolio portfolio;
  final double strokeWidth;

  MiniDonutChart(this.portfolio, {this.strokeWidth=10});

  @override
  Widget build(BuildContext context) {
    List<SegmentData> pieData = range(portfolio.nCurrentMarkets)
        .map((int i) => SegmentData(
            percentage: portfolio.sortedValues.values.toList()[i] / portfolio.currentValue,
            colour: portfolio.sortedValues.keys.toList()[i] == 'cash'
                        ? Colors.green[500]
                        : fromHex(portfolio.markets[portfolio.sortedValues.keys.toList()[i]].colours[0])))
        .toList();

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
        ..color = data.colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      end += data.percentage;

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
