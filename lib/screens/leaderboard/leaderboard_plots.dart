import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import './leaderboard_returns.dart';

double width_factor = 200;

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size(width_factor, 100),
        painter: MyPainter(),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = ui.PointMode.polygon;

    var points = [
      for (var data = 0;
          data < LeaderboardReturnsData().data[0].values!.length;
          data++)
        Offset(LeaderboardReturnsData().data[0].time![data] * 
        (width_factor / LeaderboardReturnsData().data[0].values!.length), 
        LeaderboardReturnsData().data[0].values![data])
    ];

    final paint = Paint()
      ..color = (points.last > points[0]) ? Colors.red : Colors.green
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
