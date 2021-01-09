import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/data_models/portfolios.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/colors.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

double _pi = 3.1415926535;

/// Pie chart widget wrapper: returns an animation that refires every time the page is rebuilt
class AnimatedDonutChart extends StatelessWidget {
  final Tween<double> _donutFade = Tween<double>(begin: 0, end: 1);
  final Portfolio portfolio;
  AnimatedDonutChart({this.portfolio});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      curve: Curves.easeOutSine,
      duration: Duration(milliseconds: 600),
      tween: _donutFade,
      builder: (_, double percentComlpete, __) {
        return PieChart(portfolio: portfolio, percentComplete: percentComlpete);
      },
    );
  }
}

/// Main pie chart widget: has a [percentComplete] variable that can be used for animation purposes
/// i.e. if [percentComplete] is 0.5, the pie chart will be a half-moon, filling the right side
class PieChart extends StatefulWidget {
  final double percentComplete;
  final Portfolio portfolio;

  PieChart({
    @required this.portfolio,
    @required this.percentComplete,
  });

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  double width;
  double height;
  double _portfolioValue = 0;
  int nContracts;
  List<double> _ratios = [];
  List<double> _values = [];
  List<double> _binEdges = [0.0];
  double centerText = 0;
  bool spinning = true;

  List segmentPainters = [];

  int selectedSegment;

  @override
  void initState() {
    super.initState();

    double value;
    nContracts = widget.portfolio.contracts.length;

    for (int i = 0; i < nContracts; i++) {
      value = widget.portfolio.contracts[i].price * widget.portfolio.amounts[i];
      _portfolioValue += value;
      _values.add(value);
    }

    for (int i = 0; i < nContracts; i++) {
      _ratios.add(_values[i] / _portfolioValue);
    }

    double _runningTotal = 0;

    for (int i = 0; i < nContracts; i++) {
      _runningTotal += _values[i];
      _binEdges.add(_runningTotal / _portfolioValue);
    }

    centerText = _portfolioValue;
  }

  int _getSegmentNumber(Offset offset) {
    Offset coords = offset - Offset(this.width / 2, this.height / 2);

    // if outside of a given radius, deselect all
    if (coords.distance < 0.35 * (this.width * 0.7) ||
        coords.distance > 0.65 * (this.width * 0.7)) {
      return null;
    }

    double angle = coords.direction + _pi / 2;
    double turn = ((angle + 2 * _pi) % (2 * _pi)) / (2 * _pi);

    int mid;
    int lo = 0;
    int hi = nContracts;

    while (lo < hi) {
      mid = (lo + hi) ~/ 2;
      if (_binEdges[mid] < turn)
        lo = mid + 1;
      else
        hi = mid;
    }

    return lo - 1;
  }

  DonutSegmentPainter newSegment(int i, double opacity) {
    return DonutSegmentPainter(
        label: widget.portfolio.contracts[i].name,
        start: widget.percentComplete * _binEdges[i],
        end: widget.percentComplete * _binEdges[i + 1],
        color: getColorCycle(i, nContracts),
        opacity: opacity);
  }

  List<DonutSegmentPainter> _getRefreshedSegnentPainers() {
    return range(nContracts).map((i) => newSegment(i, 0.9)).toList();
  }

  /// given that a tap just happened at [offset], highlight the apropriate pie segment
  void highlightSegment(Offset offset) {
    int newSelectedSegment = _getSegmentNumber(offset);

    if (newSelectedSegment == this.selectedSegment) {
      // no need to do anything
      return;
    }

    if (newSelectedSegment == null) {
      // deselected everything, so highlight all

      this.segmentPainters = _getRefreshedSegnentPainers();
      centerText = _portfolioValue;
    } else if (this.selectedSegment == null) {
      // currently we havent selected a segment, so must dull all segments except newly selected one

      this.segmentPainters = range(nContracts)
          .map((i) => newSegment(i, i == newSelectedSegment ? 1.0 : 0.5))
          .toList();
      centerText = _values[newSelectedSegment];
    } else {
      // just need to dull currently selected segment and highligh new segment
      this.segmentPainters[newSelectedSegment] =
          newSegment(newSelectedSegment, 1.0);
      this.segmentPainters[this.selectedSegment] =
          newSegment(this.selectedSegment, 0.5);
      centerText = _values[newSelectedSegment];
    }
    this.selectedSegment = newSelectedSegment;
  }

  @override
  Widget build(BuildContext context) {
    // set the widget width to be 70% of the screen real estate
    // this must be done in the build method
    if (this.width == null) {
      this.width = MediaQuery.of(context).size.width * 0.7;
      this.height = this.width;
    }

    // If we're still spinning up, just paint all segments with full opacity
    if (spinning) {
      this.segmentPainters = _getRefreshedSegnentPainers();
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

    // wrap whole pie section in a gestureDetector that checks which segment to highlight
    return GestureDetector(
      onTapDown: (details) {
        if (widget.percentComplete == 1) {
          setState(() {
            highlightSegment(details.localPosition);
          });
        }
      },

      // our outer container takes up the full this.width (which was 70% of
      // the entire screen space).
      // The inner container (where we paint) takes up 70% of `this` space

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
                          size: Size(this.width * 0.7, this.width * 0.7),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }
}

class DonutSegmentPainter extends CustomPainter {
  /// Painter that draws an arc segment of a pie chart
  /// [label] sets the text to be displayes in the center of the arc
  /// [start] is a number from 0-1 that sets the position round the circle to
  /// begin drawing
  /// [end] is the same, but from the end
  /// [color] and [opacity] do what you'd expect

  final String label;
  final double start;
  final double end;
  final Color color;
  final double opacity;

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
    var paint = Paint()
      ..color = this.color.withOpacity(this.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeJoin = StrokeJoin.bevel;

    // draw an arc based on the canvas size
    // this is that 70% of 70%!
    canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        2 * _pi * (this.start - 0.25),
        2 * _pi * (this.end - this.start),
        false,
        paint);

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
            color: Colors.grey[850].withOpacity(this.opacity),
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout(minWidth: 0, maxWidth: 60);
      textPainter.paint(
          canvas,
          Offset.fromDirection(
                  _pi * (this.end + this.start - 0.5), size.width * 0.6) +
              Offset(0.5 * size.width - (textPainter.width / 2),
                  0.5 * size.width - (textPainter.height / 2)));
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

  // PieChart.defaults(pcComplete)
  //     : this(contracts: [
  //         TeamContract.fromMap({
  //           'team_name': 'Arsenal',
  //           'played': 17,
  //           'goal_difference': 1,
  //           'points': 23,
  //           'image':
  //               'https://cdn.sportmonks.com/images//soccer/teams/19/19.png',
  //           'pH': [
  //             14.0,
  //             11.7,
  //             10.86,
  //             10.12,
  //             11.11,
  //             11.39,
  //             12.3,
  //             12.2,
  //             11.65,
  //             12.75,
  //             13.17,
  //             13.45,
  //             15.45,
  //             16.34,
  //             15.01,
  //             14.81,
  //             14.54,
  //             16.21,
  //             17.72,
  //             17.54,
  //             17.67,
  //             16.57,
  //             16.35,
  //             16.81,
  //             16.38
  //           ],
  //           'pD': [1],
  //           'pW': [1],
  //           'pM': [1],
  //           'pMax': [1],
  //         }),
  //         TeamContract.fromMap({
  //           'team_name': 'Aston Villa',
  //           'played': 16,
  //           'goal_difference': 2,
  //           'points': 26,
  //           'image':
  //               'https://cdn.sportmonks.com/images//soccer/teams/15/15.png',
  //           'pH': [
  //             22.0,
  //             20.05,
  //             21.67,
  //             23.27,
  //             24.47,
  //             23.17,
  //             25.38,
  //             24.41,
  //             25.9,
  //             21.92,
  //             22.66,
  //             20.58,
  //             19.83,
  //             19.18,
  //             19.43,
  //             18.79,
  //             17.39,
  //             16.91,
  //             18.07,
  //             18.61,
  //             18.16,
  //             19.1,
  //             19.16,
  //             18.42,
  //             19.91
  //           ],
  //           'pD': [1],
  //           'pW': [1],
  //           'pM': [1],
  //           'pMax': [1],
  //         }),
  //         TeamContract.fromMap({
  //           'team_name': 'Chelsea',
  //           'played': 16,
  //           'goal_difference': 7,
  //           'points': 26,
  //           'image':
  //               'https://cdn.sportmonks.com/images//soccer/teams/18/18.png',
  //           'pH': [
  //             25.0,
  //             24.08,
  //             23.29,
  //             24.13,
  //             23.51,
  //             23.5,
  //             22.12,
  //             22.0,
  //             22.71,
  //             22.04,
  //             19.92,
  //             19.64,
  //             19.47,
  //             16.42,
  //             17.66,
  //             17.31,
  //             16.63,
  //             16.48,
  //             13.7,
  //             13.56,
  //             14.85,
  //             14.72,
  //             14.74,
  //             13.68,
  //             13.74
  //           ],
  //           'pD': [1],
  //           'pW': [1],
  //           'pM': [1],
  //           'pMax': [1],
  //         }),
  //       ], amounts: [
  //         11.0,
  //         15.0,
  //         9.0
  //       ], percentComplete: pcComplete);