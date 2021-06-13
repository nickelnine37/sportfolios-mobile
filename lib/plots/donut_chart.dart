import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';
import 'package:sportfolios_alpha/utils/design/colors.dart';
import 'package:sportfolios_alpha/utils/strings/number_format.dart';

final selectedAssetProvider = ChangeNotifierProvider<SelectedAssetChangeNotifier>((ref) {
  return SelectedAssetChangeNotifier();
});

class SelectedAssetChangeNotifier with ChangeNotifier {
  String _asset;

  String get asset => _asset;

  void setAsset(String asset) {
    if (_asset != asset) {
      _asset = asset;
      notifyListeners();
    }
  }
}

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
  double radius = 100;

  @override
  Widget build(BuildContext context) {
    binEdges = [0];
    double runningTotal = 0;
    for (double value in widget.portfolio.sortedValues.values) {
      runningTotal += value;
      binEdges.add(runningTotal / widget.portfolio.currentValue);
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
          edges: binEdges,
          percentComplete: 1 + percentComlpete - endValue,
          radius: 110, // hacky business
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
  final List<double> edges;
  final double percentComplete;
  final double radius;

  PieChart({
    @required this.portfolio,
    @required this.edges,
    @required this.percentComplete,
    @required this.radius,
  });

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  double width;
  double height;
  int nMarkets;

  // aimation values
  double lowerWidth = 20;
  double upperWidth = 25;
  double lowerOpacity = 0.5;
  double upperOpacity = 0.85;
  int animationTime = 150;

  // initialise this as zero to avoid a null error
  // it takes a bit of time for initState to work
  double centerText = 0;
  bool spinning = true;

  String portfolioName;
  int currentSegment;

  @override
  void initState() {
    super.initState();
    centerText = widget.portfolio.currentValue;
    nMarkets = widget.portfolio.sortedValues.length;
    portfolioName = widget.portfolio.name;
  }

  @override
  Widget build(BuildContext context) {
    if (width == null) {
      width = MediaQuery.of(context).size.width;
    }
    if (height == null) {
      height = 1.3 * (widget.radius * 2);
    }
    if (portfolioName != null) {
      if (portfolioName != widget.portfolio.name) {
        spinning = true;
        centerText = widget.portfolio.currentValue;
        portfolioName = widget.portfolio.name;
        nMarkets = widget.portfolio.sortedValues.length;
      }
    }

    if (widget.percentComplete == 1) {
      spinning = false;
    }

    // Container for central text. Change opacity with percentComplete
    Center centralText = currentSegment == null
        ? Center(
          child: Text(formatCurrency(widget.portfolio.currentValue, 'GBP'),
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 28,
                color: Colors.grey[800].withOpacity(widget.percentComplete),
              )),
        )
        : Center(
            child: Text(
            '${widget.portfolio.markets[widget.portfolio.sortedValues.keys.toList()[currentSegment]].name}\n${formatCurrency(widget.portfolio.sortedValues.values.toList()[currentSegment], "GBP")}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 20,
              color: Colors.grey[800].withOpacity(widget.percentComplete),
            ),
          ));

    return GestureDetector(
      onTapDown: (details) {
        if (widget.percentComplete == 1) {
          int newSelectedSegment = _getSegmentNumber(details.localPosition);

          if (newSelectedSegment != currentSegment) {
            // change notifier provider!
            context.read(selectedAssetProvider).setAsset(newSelectedSegment == null
                ? null
                : widget.portfolio.sortedValues.keys.toList()[newSelectedSegment]);

            setState(() {
              currentSegment = newSelectedSegment;
            });
          }
        }
      },
      child: Container(
        width: width,
        height: height,
        child: Center(
          child: Stack(
              children: <Widget>[centralText] +
                  range(nMarkets).map((int i) {
                    String market = widget.portfolio.sortedValues.keys.toList()[i];

                    Color color = market == 'cash'
                        ? Colors.green[500]
                        : fromHex(widget.portfolio.markets[market].colours[0]);

                    if (spinning) {
                      return Center(
                        child: CustomPaint(
                            size: Size(2 * widget.radius, 2 * widget.radius),
                            painter: DonutSegmentPainter(
                                start: widget.percentComplete * widget.edges[i],
                                end: widget.percentComplete * widget.edges[i + 1],
                                color: color,
                                opacity: upperOpacity,
                                strokeWidth: lowerWidth)),
                      );
                    }
                    return TweenAnimationBuilder(
                      curve: Curves.easeOutSine,
                      duration: Duration(milliseconds: animationTime),
                      tween: Tween<Offset>(
                          begin: Offset(upperOpacity, lowerWidth),
                          end: currentSegment == i
                              ? Offset(upperOpacity, upperWidth)
                              : (currentSegment == null
                                  ? Offset(upperOpacity, lowerWidth)
                                  : Offset(lowerOpacity, lowerWidth))),
                      builder: (_, Offset offset, __) {
                        double opacity = offset.dx;
                        double width = offset.dy;
                        return Center(
                          child: CustomPaint(
                              size: Size(2 * widget.radius + (width - lowerWidth),
                                  2 * widget.radius + (width - lowerWidth)),
                              painter: DonutSegmentPainter(
                                  start: widget.edges[i],
                                  end: widget.edges[i + 1],
                                  color: color,
                                  opacity: opacity,
                                  strokeWidth: width)),
                        );
                      },
                    );
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
    if (coords.distance < 0.7 * widget.radius || coords.distance > 1.3 * widget.radius) {
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
}

class DonutSegmentPainter extends CustomPainter {
  final double start;
  final double end;
  final Color color;
  final double opacity;
  final double strokeWidth;

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
