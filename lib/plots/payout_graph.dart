import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';
import 'package:sportfolios_alpha/utils/string_utils.dart';

// class TabbedPayoutGraph extends StatefulWidget {
//   final List<double> p1;
//   final List<double> p2;
//   final Color color;
//   TabbedPayoutGraph(this.p1, this.p2, this.color);

//   @override
//   _TabbedPayoutGraphState createState() => _TabbedPayoutGraphState();
// }

// class _TabbedPayoutGraphState extends State<TabbedPayoutGraph> with SingleTickerProviderStateMixin {
//   TabController _tabController;

//   @override
//   void initState() {
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.addListener(() {
//       print('my index is' + _tabController.index.toString());
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Container(
//             // width: MediaQuery.of(context).size.width * 0.7,
//             child: Center(
//               child: Container(
//                 width: 200,
//                 height: 30,
//                 padding: EdgeInsets.only(bottom: 5, top: 2, left: 3, right: 3),
//                 child: TabBar(
//                   labelColor: Colors.grey[900],
//                   unselectedLabelColor: Colors.grey[400],
//                   indicatorColor: Colors.grey[600],
//                   indicatorWeight: 1,
//                   controller: _tabController,
//                   labelPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
//                   indicatorSize: TabBarIndicatorSize.label,
//                   tabs: [
//                     Tab(child: Text('BACK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
//                     Tab(child: Text('LAY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             child: AnimatedBuilder(
//                 animation: _tabController.animation,
//                 builder: (BuildContext context, snapshot) {
//                   return TrueStaticPayoutGraph(
//                       matrixMultiply(
//                         [widget.p1, widget.p2],
//                         [1 - _tabController.animation.value, _tabController.animation.value],
//                       ),
//                       widget.color);
//                 }),
//           ),
//         ],
//       ),
//     );
//   }
// }

class TrueStaticPayoutGraph extends StatefulWidget {
  final List<double> payouts;
  final Color color;
  final double lrPadding;
  final double height;
  final bool lock;

  TrueStaticPayoutGraph(this.payouts, this.color, this.lrPadding, this.height, this.lock);

  @override
  _TrueStaticPayoutGraphState createState() => _TrueStaticPayoutGraphState();
}

class _TrueStaticPayoutGraphState extends State<TrueStaticPayoutGraph> {
  double width;
  int selectedBar;
  double pmax;
  int n;

  int _selectedBar(Offset touchLocation) {
    int selected = (n * touchLocation.dx / width).floor();

    if (touchLocation.dy + 20 > widget.height - widget.height * widget.payouts[selected] / pmax)
      return selected;
    else
      return null;
  }

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
              size: Size(width, widget.height),
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
              size: Size(width, widget.height),
            ),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width - 2 * widget.lrPadding;
    pmax = widget.payouts.reduce(max);
    n = widget.payouts.length;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            height: 20,
            child: Text(
              selectedBar != null
                  ? '${selectedBar + 1}${formatOrdinal(selectedBar + 1)} place payout: ${formatCurrency(widget.payouts[selectedBar], 'GBP')}'
                  : 'Payout Structure',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: widget.color,
          highlightColor: widget.color.withAlpha(200),
          period: Duration(milliseconds: 3000),
          enabled: !widget.lock,
          child: widget.lock
              ? GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    int newSelectedBar = _selectedBar(details.localPosition);
                    if (newSelectedBar != selectedBar) {
                      setState(() {
                        selectedBar = newSelectedBar;
                      });
                    }
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    width: width,
                    height: widget.height,
                    child: Stack(
                      children: _rereshPainters(1),
                    ),
                  ),
                )
              : Container(
                  alignment: Alignment.topRight,
                  width: width,
                  height: widget.height,
                  child: Stack(
                    children: _rereshPainters(1),
                  ),
                ),
        )
      ],
    );
  } // decoration: BoxDecoration(
}

class StaticPayoutGraph extends StatefulWidget {
  final List<double> payouts;
  final Color color;
  StaticPayoutGraph(this.payouts, this.color);

  @override
  _StaticPayoutGraphState createState() => _StaticPayoutGraphState();
}

class _StaticPayoutGraphState extends State<StaticPayoutGraph> {
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
                              Text(formatCurrency(widget.payouts[selectedBar], currency),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
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
  } // decoration: BoxDecoration(
  //   color: Colors.black.withOpacity(0.05),
  //   borderRadius: BorderRadius.all(Radius.circular(5.0)),
  //   border: Border.all(
  //     color: Colors.grey[500],
  //     width: 1,
  //   ),
  // ),
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
    int n = payouts.length;
    double pmax = 10;
    double barWidth = 0.95 * size.width / n;
    double barHeight = percentComplete * payouts[index] * size.height / pmax;

    Paint paint = Paint()..color = color.withOpacity(opacity * (0.4 + 0.6 * payouts[index] / pmax));

    TextSpan positionText = TextSpan(
        text: (index + 1).toString(),
        style: TextStyle(
            color: Colors.grey[850].withOpacity(opacity), fontSize: 11, fontWeight: FontWeight.w400));

    TextPainter positionTextPainter =
        TextPainter(text: positionText, textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    positionTextPainter.layout(minWidth: 0, maxWidth: 60);

    positionTextPainter.paint(
        canvas, Offset((index + 0.5) * size.width / n - positionTextPainter.width / 2, size.height));

    canvas.drawRect(
        Rect.fromLTWH(index * size.width / n, size.height - barHeight, barWidth, barHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
