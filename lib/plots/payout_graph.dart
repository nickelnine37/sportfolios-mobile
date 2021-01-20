import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';
import 'package:sportfolios_alpha/utils/string_utils.dart';

// import 'dart:ui' as ui;

class PayoutGraph extends StatefulWidget {
  final List<double> payouts;
  final Color color;
  PayoutGraph(this.payouts, this.color);

  @override
  _PayoutGraphState createState() => _PayoutGraphState();
}

class _PayoutGraphState extends State<PayoutGraph> {
  double width;
  double height = 200;
  int selectedBar;
  double pmax;
  int n;

  List<CustomPaint> _rereshPainters(double percentComplete) {
    if (selectedBar == null) {
      return range(n)
          .map(
            (int i) => CustomPaint(
              painter: Bar(
                  payouts: widget.payouts,
                  index: i,
                  opacity: 1,
                  percentComplete: percentComplete,
                  color: widget.color),
              size: Size(width, height),
            ),
          )
          .toList();
    } else {
      return range(n)
          .map(
            (int i) => CustomPaint(
              painter: Bar(
                  payouts: widget.payouts,
                  index: i,
                  opacity: (i == selectedBar) ? 1 : 0.5,
                  color: widget.color),
              size: Size(width, height),
            ),
          )
          .toList();
    }
  }

  int _selectedBar(Offset touchLocation) {
    int selected = (n * touchLocation.dx / width).floor();

    if (touchLocation.dy + 20 > height - height * widget.payouts[selected] / pmax)
      return selected;
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width * 0.9;
    pmax = widget.payouts.reduce(max);
    n = widget.payouts.length;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Contract Payout Structure', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        SizedBox(height: 15),
        GestureDetector(
          onTapDown: (TapDownDetails details) {
            int newSelectedBar = _selectedBar(details.localPosition);
            if (newSelectedBar != selectedBar) {
              setState(() {
                selectedBar = newSelectedBar;
              });
            }
          },
          child: TweenAnimationBuilder(
              curve: Curves.easeOutSine,
              duration: Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0, end: 1),
              child: Consumer(builder: (context, watch, child) {
                String currency = watch(settingsProvider).currency;
                return Container(
                    padding: EdgeInsets.all(20),
                    child: (selectedBar == null)
                        ? null
                        : Column(
                            children: [
                              Text(
                                '${selectedBar + 1}${formatOrdinal(selectedBar + 1)} place payout:',
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                formatCurrency(widget.payouts[selectedBar], currency),
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300,
                              ))
                            ],
                          ));
              }),
              builder: (BuildContext context, double percentComlpete, Widget child) {
                return Container(
                  alignment: Alignment.topRight,
                  width: width,
                  height: height,
                  child: Stack(
                    children: [child] + _rereshPainters(percentComlpete),
                  ),
                );
              }),
        ),
      ],
    );
  }
}

class Bar extends CustomPainter {
  List<double> payouts;
  int index;
  double percentComplete;
  double opacity;
  Color color;

  Bar({this.payouts, this.index, this.percentComplete = 1, this.opacity = 1, this.color = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    // print(opacity);
    int n = payouts.length;
    double pmax = payouts.reduce(max);
    double barWidth = 0.95 * size.width / n;
    double barHeight = percentComplete * payouts[index] * size.height / pmax;

    Paint paint = Paint()..color = color.withOpacity(opacity * (0.4 + 0.6 * index / (n - 1)));

    TextSpan positionText = TextSpan(
      text: (index + 1).toString(),
      style: TextStyle(color: Colors.grey[850].withOpacity(opacity), fontSize: 11, fontWeight: FontWeight.w400),
    );

    TextPainter positionTextPainter =
        TextPainter(text: positionText, textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    positionTextPainter.layout(minWidth: 0, maxWidth: 60);

      positionTextPainter.paint(
        canvas,
        Offset(
          (index + 0.5) * size.width / n - positionTextPainter.width / 2,
          size.height,
        ),
      );

    canvas.drawRect(
        Rect.fromLTWH(index * size.width / n, size.height - barHeight, barWidth, barHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
