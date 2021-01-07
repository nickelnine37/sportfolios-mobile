import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/utils/colors.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

double _pi = 3.1415926535;

class AnimatedDonutChart extends StatelessWidget {
  final Tween<double> _donutFade = Tween<double>(begin: 0, end: 1);
  AnimatedDonutChart({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      curve: Curves.easeOutSine,
      duration: Duration(milliseconds: 600),
      tween: _donutFade,
      builder: (_, double percentComlpete, __) {
        return PieChart.defaults(percentComlpete);
      },
    );
  }
}

class PieChart extends StatefulWidget {
  final List<Contract> contracts;
  final List<double> amounts;
  final double percentComplete;

  PieChart(
      {@required this.contracts,
      @required this.amounts,
      @required this.percentComplete})
      : assert(contracts.length == amounts.length);

  PieChart.defaults(pcComplete)
      : this(contracts: [
          TeamContract.fromMap({
            'team_name': 'Arsenal',
            'played': 17,
            'goal_difference': 1,
            'points': 23,
            'image':
                'https://cdn.sportmonks.com/images//soccer/teams/19/19.png',
            'price24': [
              14.0,
              11.7,
              10.86,
              10.12,
              11.11,
              11.39,
              12.3,
              12.2,
              11.65,
              12.75,
              13.17,
              13.45,
              15.45,
              16.34,
              15.01,
              14.81,
              14.54,
              16.21,
              17.72,
              17.54,
              17.67,
              16.57,
              16.35,
              16.81,
              16.38
            ]
          }),
          TeamContract.fromMap({
            'team_name': 'Aston Villa',
            'played': 16,
            'goal_difference': 2,
            'points': 26,
            'image':
                'https://cdn.sportmonks.com/images//soccer/teams/15/15.png',
            'price24': [
              22.0,
              20.05,
              21.67,
              23.27,
              24.47,
              23.17,
              25.38,
              24.41,
              25.9,
              21.92,
              22.66,
              20.58,
              19.83,
              19.18,
              19.43,
              18.79,
              17.39,
              16.91,
              18.07,
              18.61,
              18.16,
              19.1,
              19.16,
              18.42,
              19.91
            ]
          }),
          TeamContract.fromMap({
            'team_name': 'Chelsea',
            'played': 16,
            'goal_difference': 7,
            'points': 26,
            'image':
                'https://cdn.sportmonks.com/images//soccer/teams/18/18.png',
            'price24': [
              25.0,
              24.08,
              23.29,
              24.13,
              23.51,
              23.5,
              22.12,
              22.0,
              22.71,
              22.04,
              19.92,
              19.64,
              19.47,
              16.42,
              17.66,
              17.31,
              16.63,
              16.48,
              13.7,
              13.56,
              14.85,
              14.72,
              14.74,
              13.68,
              13.74
            ]
          }),
        ], amounts: [
          11.0,
          15.0,
          9.0
        ], percentComplete: pcComplete);

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  final double width = 250;
  final double height = 250;
  double _portfolioValue = 0;
  int nContracts;
  List<double> _ratios = [];
  List<double> _values = [];
  List<double> _binEdges = [0.0];
  double centerText = 0;

  List segmentPainters = [];

  int selectedSegment;

  @override
  void initState() {
    super.initState();

    double value;
    nContracts = widget.contracts.length;

    for (int i = 0; i < nContracts; i++) {
      value = widget.contracts[i].price * widget.amounts[i];
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
    if (coords.distance < 60 || coords.distance > 140) {
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
      label: widget.contracts[i].name,
        start: widget.percentComplete * _binEdges[i],
        end: widget.percentComplete * _binEdges[i + 1],
        color: getColorCycle(i, nContracts),
        opacity: opacity);
  }

  void highlightSegment(Offset offset) {
    // given that a tap just happened at <offset>, highligh the apropriate pie segment

    int newSelectedSegment = _getSegmentNumber(offset);

    if (newSelectedSegment == this.selectedSegment) {
      // no need to do anything
      return;
    }

    if (newSelectedSegment == null) {
      // deselected everything, so highlight all
      this.segmentPainters = Iterable<int>.generate(nContracts)
          .map((i) => newSegment(i, 1.0))
          .toList();
      centerText = _portfolioValue;
    } else if (this.selectedSegment == null) {
      // currently we havent selected a segment, so must dull all segments except newly selected one
      this.segmentPainters = Iterable<int>.generate(nContracts)
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

    // If we're still spinning up, just paint all segments with full opacity
    if (widget.percentComplete < 1) {
      this.segmentPainters = Iterable<int>.generate(nContracts)
          .map((i) => newSegment(i, 1.0))
          .toList();
    }

    Container centralText = Container(
        width: 180,
        height: 180,
        child: Center(child: Consumer(builder: (context, watch, value) {
          String currency = watch(settingsProvider).currency;
          return Text(
            '${formatCurrency(centerText, currency)}',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 8 + 20 * widget.percentComplete,
              color: Colors.grey[800].withOpacity(widget.percentComplete),
            ),
          );
        })));

    return GestureDetector(
      onTapDown: (details) {
        if (widget.percentComplete == 1) {
          setState(() {
            highlightSegment(details.localPosition);
          });
        }
      },
      child: Container(
          width: this.width,
          height: this.height,
          // color: Colors.grey[400],
          // decoration: BoxDecoration(
          //         // color: Colors.yellow[100],
          //         border: Border.all(
          //           color: Colors.red,
          //           width: 1,
          //         )),
          child: Center(
            child: Stack(
              children: <Widget>[centralText] +
                  segmentPainters
                      .map(
                        (segment) => Container(
                            width: 180,
                            height: 180,
                            child: CustomPaint(painter: segment)),
                      )
                      .toList(),
            ),
          )),
    );
  }
}

class DonutSegmentPainter extends CustomPainter {
  final String label;
  final double start;
  final double end;
  final Color color;
  double opacity;

  DonutSegmentPainter({
    @required this.label,
    @required this.start,
    @required this.end,
    @required this.color,
    @required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = this.color.withOpacity(this.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeJoin = StrokeJoin.bevel;

    canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        2 * _pi * (this.start - 0.25),
        2 * _pi * (this.end - this.start),
        false,
        paint);

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
        textAlign: TextAlign.center);

    textPainter.layout(minWidth: 0, maxWidth: 60);
    textPainter.paint(canvas, Offset.fromDirection(_pi * (this.end + this.start - 0.5), 120) + Offset(90 - (textPainter.width / 2), 90 - (textPainter.height / 2)));

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
