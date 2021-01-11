import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
// import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/data_models/portfolios.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/colors.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

double _pi = 3.1415926535;


/// Pie chart widget wrapper: returns an animation that refires every time the page is rebuilt
/// creating an animated circle-spin effect. We also calulate some information used in the pie
/// chart here, such as the value of each asset and where the bin edges start and stop.
class AnimatedDonutChart extends StatefulWidget {
  final Portfolio portfolio;
  AnimatedDonutChart({this.portfolio});

  @override
  _AnimatedDonutChartState createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart> {

    // this is highly hacky but I can't get the TweenAnimationBuilder to refire
    // unless I keep shifting its end value on each rebuild. So basically, its 
    // incremented by one, and then the relevant amount is subtracted off endValue
  double endValue = 0;

  @override
  Widget build(BuildContext context) {

    // do some pre-computation here
    List<double> _values = [];
    List<double> _binEdges = [0.0];

    int nContracts = this.widget.portfolio.contracts.length;

    for (int i = 0; i < nContracts; i++) {
      double value = this.widget.portfolio.contracts[i].price * this.widget.portfolio.amounts[i];
      _values.add(value);
    }

    // note, bin edges are cacluated in metric angle! i.e. 0=>0, 2pi=>1
    double _runningTotal = 0;
    for (double value in _values) {
      _runningTotal += value;
      _binEdges.add(_runningTotal / this.widget.portfolio.value);
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
          contractValues: _values,
          binEdges: _binEdges,
          percentComplete: 1 + percentComlpete - endValue, // hacky business
        );
      },
    );
  }
}

/// Main pie chart widget: has a [percentComplete] variable that can be used for animation purposes
/// i.e. if [percentComplete] is 0.5, the pie chart will be a half-moon, filling the right side.
/// Some of the vairables passed technically are redundant as they could all be computed from other values
/// (i.e. [portfolioValue], [contractValues] and [binEdges] could all be calculated from [portfolio])
/// however since the class is being called many times in the opening animation, it's more efficient to
/// precompute these things and pass them as an argument.
class PieChart extends StatefulWidget {
  final Portfolio portfolio;
  final List<double> contractValues;
  final List<double> binEdges;
  final double percentComplete;

  PieChart({
    @required this.portfolio,
    @required this.contractValues,
    @required this.binEdges,
    @required this.percentComplete,
  });

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  // these will be the width and height of the container holding
  // the donut chart iteself.
  double width;
  double height;
  int nContracts;

  // initialise this as zero to avoid a null error
  // it takes a bit of time for initState to work
  double centerText = 0;
  bool spinning = true;
  List segmentPainters = [];
  int selectedSegment;
  String portfolioName;

  // this refers to the information on the left that needs to change
  // when a segment is selected
  // [asset] refers to the selected asset/segment. needs to be dynamic as sometimes
  // it can be a specific Contract, sometimes it can be a Portfolio
  dynamic asset;

  // wf1 => how much of the total screen width should the pie chart container take?
  // wf2 => how much of the donut chart container should the actual donut take?
  final double widthFactor1 = 0.65;
  final double widthFactor2 = 0.6;

  @override
  void initState() {
    super.initState();
    centerText = widget.portfolio.value;
    nContracts = widget.contractValues.length;
    portfolioName = widget.portfolio.name;
  }

  @override
  Widget build(BuildContext context) {
    
    // set the widget width to be [widthFactor1] of the screen real estate
    // this must be done at build time
    if (this.width == null) {
      this.width = MediaQuery.of(context).size.width * widthFactor1;
      this.height = this.width;
    }

    if (portfolioName != null) {
      if (portfolioName != widget.portfolio.name) {
        spinning = true;
        centerText = widget.portfolio.value;
        portfolioName = widget.portfolio.name;
        asset = widget.portfolio;
        nContracts = widget.portfolio.amounts.length;
      }
    }

    // If we're still spinning up, just paint all segments with full opacity
    // this needs to be called on each build, as percentComplete is changing
    if (spinning) {
      this.segmentPainters = _getRefreshedSegnentPainers();
    }

    if (asset == null) {
      asset = widget.portfolio;
    }

    if (widget.percentComplete == 1) {
      spinning = false;
    }

    // Container for central text. Change opacity with percentComplete
    Center centralText = Center(
      child: Consumer(builder: (context, watch, value) {
        String currency = watch(settingsProvider).currency;
        return Text(
          '${formatCurrency(centerText, currency)}',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 28,
            color: Colors.grey[800].withOpacity(widget.percentComplete),
          ),
        );
      }),
    );

    return Column(
      children: [
        Center(
          child: Container(
            child: Center(
              child: Text(this.selectedSegment == null ? 'Portfolio Overview' : '${asset.name} (${asset.longShort})', 
                // asset.name + "${this.selectedSegment == null ? '' : ' (${asset.longShort})'}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
            ),
            padding: EdgeInsets.only(top: 10),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 28, bottom: 33, left: 3, right: 3),
                height: this.height,
                // color: Colors.grey[400],
                child: Consumer(
                  builder: (context, watch, value) {
                    String currency = watch(settingsProvider).currency;
                    int amount =
                        (this.selectedSegment == null) ? 1 : widget.portfolio.amounts[this.selectedSegment];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _portfolioInfoBox('Return (1 hour)', amount * asset.hourReturn,
                            amount * asset.hourValueChange, widget.percentComplete, currency),
                        _portfolioInfoBox('Return (24 hours)', amount * asset.dayReturn,
                            amount * asset.dayValueChange, widget.percentComplete, currency),
                        _portfolioInfoBox('Return (7 days)', amount * asset.weekReturn,
                            amount * asset.weekValueChange, widget.percentComplete, currency),
                        _portfolioInfoBox('Return (28 days)', amount * asset.monthReturn,
                            amount * asset.monthValueChange, widget.percentComplete, currency),
                      ],
                    );
                  },
                ),
              ),
            ),

            // wrap donut container in a gestureDetector that checks which segment to highlight
            GestureDetector(
              onTapDown: (details) {
                if (widget.percentComplete == 1) {
                  setState(() {
                    highlightSegment(details.localPosition);
                  });
                }
              },
              // our outer container takes up the full this.width (which was 70% of
              // the entire screen space).
              // The inner container (where we paint) takes up 60% of `this` space
              child: Container(
                width: this.width,
                height: this.width,
                child: Center(
                  child: Stack(
                    children: <Widget>[centralText] +
                        segmentPainters
                            .map(
                              (segment) => Center(
                                child: CustomPaint(
                                  painter: segment,
                                  size: Size(this.width * widthFactor2, this.width * widthFactor2),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Function that takes in an offset, which is the coordinates that have just been tapped
  /// by the user, and then calculates which segment of the donut should be highlighted.
  int _getSegmentNumber(Offset offset) {
    // translate coordinates so that the origin is central
    Offset coords = offset - Offset(this.width / 2, this.height / 2);

    // if outside of a given radius, deselect all
    if (coords.distance < 0.35 * (this.width * widthFactor2) ||
        coords.distance > 0.65 * (this.width * widthFactor2)) {
      return null;
    }

    double angle = coords.direction + _pi / 2;
    double turn = ((angle + 2 * _pi) % (2 * _pi)) / (2 * _pi);

    // binary search implementation!! Should be much faster than naive method for large donuts
    // https://github.com/python/cpython/blob/master/Lib/bisect.py
    int mid;
    int lo = 0;
    int hi = nContracts;

    while (lo < hi) {
      mid = (lo + hi) ~/ 2;
      if (widget.binEdges[mid] < turn)
        lo = mid + 1;
      else
        hi = mid;
    }

    return lo - 1;
  }

  /// Helper function to return a painter for arc number i, with a given opacity
  DonutSegmentPainter newSegment(int i, double opacity) {
    return DonutSegmentPainter(
        label: widget.portfolio.contracts[i].name,
        start: widget.percentComplete * widget.binEdges[i],
        end: widget.percentComplete * widget.binEdges[i + 1],
        color: getColorCycle(i, nContracts),
        opacity: opacity);
  }

  /// Helper function to return a list of arc painters all with opacity 0.9
  List<DonutSegmentPainter> _getRefreshedSegnentPainers() {
    return range(nContracts).map((i) => newSegment(i, 0.9)).toList();
  }

  /// given that a tap just happened at [offset], highlight the apropriate pie segment
  /// and make other changes to the UI such as changing the central value figure and
  /// information bar
  void highlightSegment(Offset offset) {
    int newSelectedSegment = _getSegmentNumber(offset);

    if (newSelectedSegment == this.selectedSegment) {
      // no need to do anything
      return;
    }

    if (newSelectedSegment == null) {
      // we just deselected everything, so highlight all

      this.segmentPainters = _getRefreshedSegnentPainers();
      centerText = widget.portfolio.value;
      asset = widget.portfolio;
    }

    // handle two situations differently:
    // 1. we curently have no selected segment
    // 2. we have a currently selected segment

    else {
      if (this.selectedSegment == null) {
        // should dull all segments except newly selected one
        this.segmentPainters =
            range(nContracts).map((i) => newSegment(i, i == newSelectedSegment ? 1.0 : 0.5)).toList();
      } else {
        // just need to dull currently selected segment and highligh new segment
        this.segmentPainters[newSelectedSegment] = newSegment(newSelectedSegment, 1.0);
        this.segmentPainters[this.selectedSegment] = newSegment(this.selectedSegment, 0.5);
      }

      centerText = widget.contractValues[newSelectedSegment];
      asset = widget.portfolio.contracts[newSelectedSegment];
    }

    this.selectedSegment = newSelectedSegment;
  }
}

/// helper function to reduce boilerplate
/// just returns a column containing the text followed
/// by the formated returns
Widget _portfolioInfoBox(
  String text,
  double retrn,
  double valueChange,
  double opacity,
  String currency,
) {
  return Column(
    children: [
      Center(
          child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[800].withOpacity(opacity)),
      )),
      SizedBox(height: 4),
      Center(
        child: Text(
          '${retrn > 0 ? "+" : "-"}' +
              formatPercentage(retrn.abs(), currency) +
              '  (${retrn > 0 ? "+" : "-"}' +
              formatCurrency(valueChange.abs(), currency) +
              ')',
          style: TextStyle(
            fontSize: 12,
            color: retrn > 0 ? Colors.green.withOpacity(opacity) : Colors.red.withOpacity(opacity),
          ),
        ),
      ),
    ],
  );
}

/// Painter that draws an arc segment of a pie chart
/// [label] sets the text to be displayes in the center of the arc
/// [start] is a number from 0-1 that sets the position round the circle to
/// begin drawing
/// [end] is the same, but from the end
/// [color] and [opacity] do what you'd expect
class DonutSegmentPainter extends CustomPainter {
  final String label;
  final double start;
  final double end;
  final Color color;
  final double opacity;
  // hacky - but this needs to be set in two places
  final double widthFactor2 = 0.6;

  DonutSegmentPainter({
    @required this.label,
    @required this.start,
    @required this.end,
    @required this.color,
    @required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // paint for the arc
    Paint arcPaint = Paint()
      ..color = this.color.withOpacity(this.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    Paint shadowPaint = Paint()
      ..color = Colors.grey[500].withOpacity(this.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);

    Path path = Path();
    double startAngle = 2 * _pi * (this.start - 0.25);
    double endAngle = 2 * _pi * (this.end - this.start);

    path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), startAngle, endAngle);

    canvas.drawPath(path.shift(Offset(2, 2)), shadowPaint);
    canvas.drawPath(path, arcPaint);

    // draw an arc based on the canvas size
    // this is that 70% of 70%!
    // canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), 2 * _pi * (this.start - 0.25),
    //     2 * _pi * (this.end - this.start), false, paint);

    // lets only paint the labels on if:
    // 1. This segment is selected, or
    // 2. the contract takes up more than 8% of the portfolio
    // otherwiss will get very crowded

    if (this.opacity == 1 || (this.end - this.start) > 0.08) {
      // painter for the contract labels round the arc
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: this.label,
          style: TextStyle(
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.grey[100],
                offset: Offset(1, 0),
              )
            ],
            color: Colors.grey[850].withOpacity(this.opacity),
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout(minWidth: 0, maxWidth: 0.5 * size.width * (1 / widthFactor2 - 1));
      textPainter.paint(
          canvas,
          Offset.fromDirection(_pi * (this.end + this.start - 0.5), size.width * widthFactor2) +
              Offset(
                  0.5 * size.width - (textPainter.width / 2), 0.5 * size.width - (textPainter.height / 2)));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// color: Colors.grey[400],
// decoration: BoxDecoration(
//         // color: Colors.yellow[100],
//         border: Border.all(
//           color: Colors.red,
//           width: 1,
//         )),
