
import 'package:flutter/material.dart';
import './pie_data.dart';

double pi = 3.1415926535;

class MiniDonutChart extends StatelessWidget {

  final List<SegmentData> pieData;

  MiniDonutChart(this.pieData);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      child: CustomPaint(painter: MiniDonutChartPainter(this.pieData)),
    );
  }
}

class MiniDonutChartPainter extends CustomPainter {

  final List<SegmentData> pieData;
  double start = 0;
  double end = 0;

  MiniDonutChartPainter(this.pieData);

  @override
  void paint(Canvas canvas, Size size) {

    SegmentData data;

    for (data in pieData) {
      Paint arcPaint = Paint()
      ..color = data.colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 ;

      end += data.percentage / 100;

      Path path = Path();
      double startAngle = 2 * pi * (this.start - 0.25);
      double endAngle = 2 * pi * (this.end - this.start);

      print(start);

      start = end;

      print(end);

      path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), startAngle, endAngle);

      canvas.drawPath(path, arcPaint);

    } 

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

}