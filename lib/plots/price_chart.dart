import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/strings/string_utils.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../utils/numerical/arrays.dart';
import '../utils/numerical/array_operations.dart';
import '../utils/strings/number_format.dart';

class TabbedPriceGraph extends StatefulWidget {
  final Map<String, Array>? priceHistory;
  final Map<String, List<int>>? times;
  final Color color1 = Colors.green;
  final Color color2 = Colors.green;
  final double height;
  final bool include_return;

  const TabbedPriceGraph({
    required this.priceHistory,
    required this.times,
    this.include_return = true,
    this.height = 300,
  });

  @override
  _TabbedPriceGraphState createState() => _TabbedPriceGraphState();
}

class _TabbedPriceGraphState extends State<TabbedPriceGraph> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int selected = 0;

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        selected = _tabController!.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<int> lengths = [
      math.min(widget.priceHistory!['M']!.length, widget.times!['M']!.length),
      math.min(widget.priceHistory!['m']!.length, widget.times!['m']!.length),
      math.min(widget.priceHistory!['w']!.length, widget.times!['w']!.length),
      math.min(widget.priceHistory!['d']!.length, widget.times!['d']!.length),
      math.min(widget.priceHistory!['h']!.length, widget.times!['h']!.length),
    ];

    int maxLen = lengths.reduce(math.max);

    List<Array> ps = [
      widget.priceHistory!['M']!
          .sublist(0, lengths[0])
          .extendLeft(List<double>.filled(maxLen - lengths[0], widget.priceHistory!['M']!.first)),
      widget.priceHistory!['m']!
          .sublist(0, lengths[1])
          .extendLeft(List<double>.filled(maxLen - lengths[1], widget.priceHistory!['m']!.first)),
      widget.priceHistory!['w']!
          .sublist(0, lengths[2])
          .extendLeft(List<double>.filled(maxLen - lengths[2], widget.priceHistory!['w']!.first)),
      widget.priceHistory!['d']!
          .sublist(0, lengths[3])
          .extendLeft(List<double>.filled(maxLen - lengths[3], widget.priceHistory!['d']!.first)),
      widget.priceHistory!['h']!
          .sublist(0, lengths[4])
          .extendLeft(List<double>.filled(maxLen - lengths[4], widget.priceHistory!['h']!.first)),
    ];

    List<Array> ts = [
      Array.fromTrueDynamicList(widget.times!['M']!.sublist(0, lengths[0]))
          .extendLeft(List<double>.filled(maxLen - lengths[0], widget.times!['M']!.first + 0.0)),
      Array.fromTrueDynamicList(widget.times!['m']!.sublist(0, lengths[1]))
          .extendLeft(List<double>.filled(maxLen - lengths[1], widget.times!['m']!.first + 0.0)),
      Array.fromTrueDynamicList(widget.times!['w']!.sublist(0, lengths[2]))
          .extendLeft(List<double>.filled(maxLen - lengths[2], widget.times!['w']!.first + 0.0)),
      Array.fromTrueDynamicList(widget.times!['d']!.sublist(0, lengths[3]))
          .extendLeft(List<double>.filled(maxLen - lengths[3], widget.times!['d']!.first + 0.0)),
      Array.fromTrueDynamicList(widget.times!['h']!.sublist(0, lengths[4]))
          .extendLeft(List<double>.filled(maxLen - lengths[4], widget.times!['h']!.first + 0.0)),
    ];

    List<List<int>> minMaxs = [
      [ps[0].argmin, ps[0].argmax],
      [ps[1].argmin, ps[1].argmax],
      [ps[2].argmin, ps[2].argmax],
      [ps[3].argmin, ps[3].argmax],
      [ps[4].argmin, ps[4].argmax],
    ];

    return DefaultTabController(
      length: 5,
      child: Container(
        height: widget.height,
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: AnimatedBuilder(
                builder: (context, child) {
                  int g1 = _tabController!.previousIndex;
                  int g2 = _tabController!.index;
                  double pcComplete = (g1 == g2) ? 0 : (_tabController!.animation!.value - g1) / (g2 - g1);

                  Array p = ps[g1].scale(1 - pcComplete) + ps[g2].scale(pcComplete);
                  Array t = ts[g1].scale(1 - pcComplete) + ts[g2].scale(pcComplete);

                  return PriceGraph(
                    price: p,
                    time: t,
                    height: widget.height * 5 / 6,
                    iMin: p.argmin,
                    iMax: p.argmax,
                    moving: _tabController!.indexIsChanging,
                  );
                },
                animation: _tabController!.animation!,
              ),
            ),
            Expanded(
              flex: 1,
              child: TabBar(
                labelColor: Colors.grey[800],
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Colors.grey[600],
                indicatorWeight: 1,
                controller: _tabController,
                labelPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(child: Text('Max', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                  Tab(child: Text('1M', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                  Tab(child: Text('1w', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                  Tab(child: Text('1d', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                  Tab(child: Text('2h', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceGraph extends StatefulWidget {
  final Array price;
  final Array time;
  final double height;
  final int iMin;
  final int iMax;
  final bool moving;

  PriceGraph({required this.price, required this.time, required this.height, required this.iMin, required this.iMax, required this.moving});

  @override
  _PriceGraphState createState() => _PriceGraphState();
}

class _PriceGraphState extends State<PriceGraph> {
  double horizontalPadding = 5.0;
  double verticalPadding = 5.0;

  double graphPadHorizontal = 10.0;
  double graphPadVertical = 10.0;

  double? graphWidth;
  double? graphHeight;

  double? tSelect;
  double? pSelect;
  double? iSelect;

  double? p0;

  void interact(Offset position) {
    if (!widget.moving) {
      if (position.dx > graphPadHorizontal && position.dx < graphWidth! - graphPadHorizontal) {
        setState(
          () {
            double ratio = (position.dx - graphPadHorizontal) / (graphWidth! - 2 * graphPadHorizontal);
            tSelect = ratio * widget.time.last + (1 - ratio) * widget.time.first;
            iSelect = sortedIndex(widget.time, tSelect!);
            pSelect = (1 - (iSelect! % 1)) * widget.price[iSelect!.floor()] + (iSelect! % 1) * widget.price[iSelect!.ceil()];
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (p0 == null) {
      p0 = widget.price.first;
    }

    if (p0 != widget.price.first) {
      iSelect = null;
      pSelect = null;
      tSelect = null;
      p0 = widget.price.first;
    }

    if (graphWidth == null) {
      graphWidth = MediaQuery.of(context).size.width - 2 * horizontalPadding;
      graphHeight = widget.height * 5 / 6 - 2 * verticalPadding;
    }

    if (widget.moving) {
      iSelect = null;
      pSelect = null;
      tSelect = null;
    }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: GraphHeader(tSelect, pSelect),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: Container(
              // color: Colors.blue.withOpacity(0.2),
              width: double.infinity,
              child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    interact(details.localPosition);
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    interact(details.localPosition);
                  },
                  child: CustomPaint(
                    painter: GraphPainter(
                        price: widget.price,
                        time: widget.time,
                        pSelect: pSelect,
                        tSelect: tSelect,
                        iSelect: iSelect,
                        iMax: widget.iMax,
                        iMin: widget.iMin,
                        padHorizontal: graphPadHorizontal,
                        padVertical: graphPadVertical),
                  )),
            ),
          ),
        )
      ],
    );
  }
}

double sortedIndex(Array array, double a, [int? start, int? end]) {
  if (start == null) {
    start = 0;
    end = array.length - 1;
    if (a > array[end]) {
      return double.infinity;
    } else if (a < array[0]) {
      return -1.0;
    }
  }

  if (start <= end!) {
    int mid = (start + end) ~/ 2;
    if (a > array[mid] && a < array[mid + 1]) return mid + (a - array[mid]) / (array[mid + 1] - array[mid]);
    if (a > array[mid]) {
      return sortedIndex(array, a, mid + 1, end);
    } else {
      return sortedIndex(array, a, start, mid - 1);
    }
  }

  return -1.0;
}

class GraphHeader extends StatefulWidget {
  final double? tSelect;
  final double? pSelect;

  const GraphHeader(double? this.tSelect, double? this.pSelect);

  @override
  _GraphHeaderState createState() => _GraphHeaderState();
}

class _GraphHeaderState extends State<GraphHeader> {
  double? tLast;
  double? pLast;

  @override
  Widget build(BuildContext context) {
    if (pLast != widget.pSelect && widget.pSelect != null) {
      pLast = widget.pSelect;
      tLast = widget.tSelect;
    }

    if (tLast == null) {
      tLast = 0.0;
      pLast = 0.0;
    }

    return AnimatedOpacity(
      opacity: widget.tSelect == null ? 0 : 1,
      duration: Duration(milliseconds: 200),
      child: Text('${unixToDateString(tLast!.floor())}:   ${formatCurrency(pLast, 'GBP')}'),
    );
  }
}

class GraphPainter extends CustomPainter {
  Array price;
  Array time;
  double? tSelect;
  double? pSelect;
  double? iSelect;
  int iMax;
  int iMin;
  double padHorizontal;
  double padVertical;

  late bool flat;
  late double pMin;
  late double pMax;
  late double tMin;
  late double tMax;

  Color lineColor = Colors.green;
  Color shadeColor = Colors.green;

  GraphPainter({
    required this.price,
    required this.time,
    required this.pSelect,
    required this.tSelect,
    required this.iSelect,
    required this.iMax,
    required this.iMin,
    required this.padHorizontal,
    required this.padVertical,
  }) {
    pMin = price[iMin];
    pMax = price[iMax];
    tMin = time[iMin];
    tMax = time[iMax];
    flat = (pMin - pMax).abs() < 1e-4;
  }

  double tToPx(num t, Size size) {
    return padHorizontal + (size.width - 2 * padHorizontal) * (t - time.first) / (time.last - time.first);
  }

  double pToPy(num p, Size size) {
    if (flat) {
      return size.height / 2;
    }
    return padVertical + (size.height - 2 * padVertical) * (1 - (p - pMin) / (pMax - pMin));
  }

  void paintGraphSection(
    Canvas canvas,
    Size size,
    Array pathX,
    Array pathY,
    double opacityMultiple,
  ) {
    Paint linePaint = Paint()
      ..color = lineColor.withOpacity(opacityMultiple)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    Paint shadePaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0
      ..shader = ui.Gradient.linear(
        Offset(100, 0),
        Offset(100, 180),
        [
          shadeColor.withOpacity(0.45 * opacityMultiple),
          shadeColor.withOpacity(0.04 * opacityMultiple),
        ],
      );

    Path graphLine = Path();
    Path shading = Path();

    int pathLength = pathX.length;

    graphLine.moveTo(pathX.first, pathY.first);
    shading.moveTo(pathX.first, pathY.first);

    for (int i = 1; i < pathLength; i++) {
      if (i < pathLength - 3) {
        graphLine.lineTo(pathX[i], pathY[i]);
      }
      shading.lineTo(pathX[i], pathY[i]);
    }

    canvas.drawPath(graphLine, linePaint);
    canvas.drawPath(shading, shadePaint);
  }

  void paintTouchLine(Canvas canvas, Size size) {
    Path touchLine = Path();

    double tP = tToPx(tSelect!, size);

    touchLine.moveTo(tP, padVertical);

    for (int i in range(21)) {
      double h1 = padVertical + (2 * i / 40) * (size.height - 2 * padVertical);
      double h2 = padVertical + (((2 * i) + 1) / 40) * (size.height - 2 * padVertical);
      touchLine.lineTo(tP, h1);
      touchLine.moveTo(tP, h2);
    }

    Paint touchLinePaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(touchLine, touchLinePaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (iSelect == null) {
      paintGraphSection(
        canvas,
        size,
        time.extend([time.last, time.first, time.first]).apply((double t) => tToPx(t, size)),
        price.extend([pMin, pMin, price.first]).apply((double p) => pToPy(p, size)),
        1.0,
      );
    } else {
      paintGraphSection(
        canvas,
        size,
        time.sublist(0, iSelect!.ceil()).extend([tSelect!, tSelect!, time.first, time.first]).apply((double t) => tToPx(t, size)),
        price.sublist(0, iSelect!.ceil()).extend([pSelect!, pMin, pMin, price.first]).apply((double p) => pToPy(p, size)),
        1.0,
      );
      paintGraphSection(
        canvas,
        size,
        time.sublist(iSelect!.ceil()).extendLeft([tSelect!]).extend([time.last, tSelect!, tSelect!]).apply((double t) => tToPx(t, size)),
        price.sublist(iSelect!.ceil()).extendLeft([pSelect!]).extend([pMin, pMin, pSelect!]).apply((double p) => pToPy(p, size)),
        0.3,
      );
      paintTouchLine(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

