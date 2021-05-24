import 'dart:collection';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/colors.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

double _pi = 3.1415926535;

/// Pie chart widget wrapper: returns an animation that refires every time the page is rebuilt
/// creating an animated circle-spin effect. We also calulate some information used in the pie
/// chart here, such as the value of each asset and where the bin edges start and stop.
class AnimatedDonutChart extends StatefulWidget {
  final Portfolio portfolio;
  AnimatedDonutChart(this.portfolio);

  @override
  _AnimatedDonutChartState createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart> {
  // this is highly hacky but I can't get the TweenAnimationBuilder to refire
  // unless I keep shifting its end value on each rebuild. So basically, its
  // incremented by one, and then the relevant amount is subtracted off endValue
  double endValue = 0;
  List<double> binEdges;
  LinkedHashMap<String, double> sortedValues;
  double radius = 100;

  @override
  Widget build(BuildContext context) {
    // do some pre-computation here
    if (sortedValues == null) {
      // sort the portfolios value map, ordered by asset value

      sortedValues = LinkedHashMap.fromIterable(
          widget.portfolio.currentValues.keys.toList(growable: false)
            ..sort(
                (k1, k2) => widget.portfolio.currentValues[k1].compareTo(widget.portfolio.currentValues[k2])),
          key: (k) => k,
          value: (k) => widget.portfolio.currentValues[k]);
    }

    if (binEdges == null) {
      binEdges = [0];
      double runningTotal = 0;
      for (double value in widget.portfolio.currentValues.values) {
        runningTotal += value;
        binEdges.add(runningTotal / widget.portfolio.currentValue);
      }
    }
    // increment endValue here
    endValue += 1;

    return TweenAnimationBuilder(
      curve: Curves.easeOutSine,
      duration: Duration(milliseconds: 600),
      // insert endValue here
      tween: Tween<double>(begin: 0, end: endValue),
      builder: (_, double percentComlpete, __) {
        return PieChart(
          portfolio: widget.portfolio,
          values: sortedValues,
          edges: binEdges,
          percentComplete: 1 + percentComlpete - endValue, // hacky business
        );
      },
    );
  }
}

/// Main pie chart widget: has a [percentComplete] variable that can be used for animation purposes
/// i.e. if [percentComplete] is 0.5, the pie chart will be a half-moon, filling the right side.
/// Some of the vairables passed technically are redundant as they could all be computed from other values
/// (i.e. [portfolioValue], [marketValues] and [binEdges] could all be calculated from [portfolio])
/// however since the class is being called many times in the opening animation, it's more efficient to
/// precompute these things and pass them as an argument.
class PieChart extends StatefulWidget {
  final Portfolio portfolio;
  final LinkedHashMap<String, double> values;
  final List<double> edges;
  final double percentComplete;

  PieChart({
    @required this.portfolio,
    @required this.values,
    @required this.edges,
    @required this.percentComplete,
  });

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  // these will be the width and height of the container holding
  // the donut chart iteself.
  double width;
  double radius = 115;
  double height = 1.5 * (115 * 2);
  int nMarkets;

  // aimation values
  double widthIncrese = 8;
  int growTime = 150;

  // initialise this as zero to avoid a null error
  // it takes a bit of time for initState to work
  double centerText = 0;
  bool spinning = true;
  List segmentPainters = [];
  int selectedSegment;
  String portfolioName;

  int previousSegment;
  int currentSegment;

  double widthFactor2;

  List<Widget> segments;

  @override
  void initState() {
    super.initState();
    centerText = widget.portfolio.currentValue;
    nMarkets = widget.values.length;
    portfolioName = widget.portfolio.name;
  }

  @override
  Widget build(BuildContext context) {
    widthFactor2 = 0.57;

    // set the widget width to be [widthFactor1] of the screen real estate
    // this must be done at build time
    if (width == null) {
      width = MediaQuery.of(context).size.width;
    }
    if (portfolioName != null) {
      if (portfolioName != widget.portfolio.name) {
        spinning = true;
        centerText = widget.portfolio.currentValue;
        portfolioName = widget.portfolio.name;
        nMarkets = widget.values.length;
      }
    }

    if (widget.percentComplete == 1) {
      spinning = false;
    }

    // Container for central text. Change opacity with percentComplete
    Center centralText = Center(
        child: Text(
      '${currentSegment == null ? "Current value" : widget.portfolio.currentMarkets[widget.values.keys.toList()[currentSegment]].name}\n${formatCurrency(centerText, "GBP")}',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 24,
        color: Colors.grey[800].withOpacity(widget.percentComplete),
      ),
    ));


    return GestureDetector(
      onTapDown: (details) {
        if (widget.percentComplete == 1) {
          selectSegment(details.localPosition);
        }
      },
      child: Container(
        width: width,
        height: height,
        child: Center(
          child: Stack(
              children: <Widget>[centralText] +
                  range(nMarkets).map((int i) {
                    if (spinning) {
                      return Center(
                        child: CustomPaint(
                            size: Size(2 * radius, 2 * radius),
                            painter: DonutSegmentPainter(
                                start: widget.percentComplete * widget.edges[i],
                                end: widget.percentComplete * widget.edges[i + 1],
                                color: getColorCycle(i, nMarkets),
                                opacity: 1,
                                strokeWidth: 20)),
                      );
                    }

                    if (i == currentSegment) {
                      return TweenAnimationBuilder(
                        curve: Curves.easeOutSine,
                        duration: Duration(milliseconds: growTime),
                        // insert endValue here
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (_, double percentComplete, __) {
                          return Center(
                            child: CustomPaint(
                                size: Size(2 * radius + widthIncrese * percentComplete,
                                    2 * radius + widthIncrese * percentComplete),
                                painter: DonutSegmentPainter(
                                    start: widget.edges[i],
                                    end: widget.edges[i + 1],
                                    color: getColorCycle(i, nMarkets),
                                    opacity: previousSegment == null ? 1 : 0.5 + percentComplete * 0.5,
                                    strokeWidth: 20 + widthIncrese * percentComplete)),
                          );
                        },
                      );
                    } else if (i == previousSegment) {
                      return TweenAnimationBuilder(
                        curve: Curves.easeOutSine,
                        duration: Duration(milliseconds: growTime),
                        // insert endValue here
                        tween: Tween<double>(begin: 1, end: 0),
                        builder: (_, double percentComplete, __) {
                          return Center(
                            child: CustomPaint(
                                size: Size(2 * radius + widthIncrese * percentComplete,
                                    2 * radius + widthIncrese * percentComplete),
                                painter: DonutSegmentPainter(
                                    start: widget.edges[i],
                                    end: widget.edges[i + 1],
                                    color: getColorCycle(i, nMarkets),
                                    opacity: currentSegment == null ? 1 : 0.5 + percentComplete * 0.5,
                                    strokeWidth: 20 + widthIncrese * percentComplete)),
                          );
                        },
                      );
                    } else {
                      return TweenAnimationBuilder(
                        curve: Curves.easeOutSine,
                        duration: Duration(milliseconds: growTime),
                        tween: new Tween<double>(begin: 0, end: 1),
                        builder: (_, double percentComplete, __) {
                          return Center(
                            child: CustomPaint(
                                size: Size(2 * radius, 2 * radius),
                                painter: DonutSegmentPainter(
                                    start: widget.edges[i],
                                    end: widget.edges[i + 1],
                                    color: getColorCycle(i, nMarkets),
                                    opacity: currentSegment == null ? 0.5 + percentComplete * 0.5 : 1 - percentComplete * 0.5,
                                    strokeWidth: 20)),
                          );
                        },
                      );
                    }
                  }).toList()),
        ),
      ),
    );
  }

  /// Function that takes in an offset, which is the coordinates that have just been tapped
  /// by the user, and then calculates which segment of the donut should be highlighted.
  int _getSegmentNumber(Offset offset) {
    // translate coordinates so that the origin is central
    Offset coords = offset - Offset(width / 2, height / 2);

    // if outside of a given radius, deselect all
    if (coords.distance < 0.7 * radius || coords.distance > 1.3 * radius) {
      return null;
    }

    double angle = coords.direction + _pi / 2;
    double turn = ((angle + 2 * _pi) % (2 * _pi)) / (2 * _pi);

    // binary search implementation!! Should be much faster than naive method for large donuts
    // https://github.com/python/cpython/blob/master/Lib/bisect.py
    int mid;
    int lo = 0;
    int hi = nMarkets;

    while (lo < hi) {
      mid = (lo + hi) ~/ 2;
      if (widget.edges[mid] < turn)
        lo = mid + 1;
      else
        hi = mid;
    }

    return lo - 1;
  }

  /// given that a tap just happened at [offset], highlight the apropriate pie segment
  /// and make other changes to the UI such as changing the central value figure and
  /// information bar
  void selectSegment(Offset offset) {
    int newSelectedSegment = _getSegmentNumber(offset);

    if (newSelectedSegment == currentSegment) {
      return;
    }

    setState(() {
      previousSegment = currentSegment;
      currentSegment = newSelectedSegment;
      centerText = newSelectedSegment == null
          ? widget.portfolio.currentValue
          : widget.values.values.toList()[newSelectedSegment];
    });
  }
}

class DonutSegmentPainter extends CustomPainter {
  final double start;
  final double end;
  final Color color;
  final double opacity;
  final double strokeWidth;
  // hacky - but this needs to be set in two places
  final double widthFactor2 = 0.6;

  DonutSegmentPainter({
    @required this.start,
    @required this.end,
    @required this.color,
    @required this.opacity,
    @required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    double startAngle = 2 * _pi * (start - 0.25);
    double endAngle = 2 * _pi * (end - start);

    Paint arcPaint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Path path = Path();

    path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), startAngle, endAngle);
    canvas.drawPath(path, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
