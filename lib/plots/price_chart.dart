import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/numerical/arrays.dart';
import '../utils/numerical/array_operations.dart';
import 'dart:ui' as ui;
import '../utils/strings/number_format.dart';
import 'package:intl/intl.dart' as intl;

class TabbedPriceGraph extends StatefulWidget {
  final Map<String, Array>? priceHistory;
  final Map<String, List<int>>? times;
  final Color color1;
  final Color color2;
  final double height;

  const TabbedPriceGraph({
    required this.priceHistory,
    required this.times,
    this.color1 = Colors.green,
    this.color2 = Colors.green,
    this.height = 300,
  });

  @override
  _TabbedPriceGraphState createState() => _TabbedPriceGraphState();
}

class _TabbedPriceGraphState extends State<TabbedPriceGraph> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final double horizontalPadding = 15;
  final double veritcalPadding = 10;
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
    List<Array> ps = [
      widget.priceHistory!['M']!,
      widget.priceHistory!['m']!,
      widget.priceHistory!['w']!,
      widget.priceHistory!['d']!,
      widget.priceHistory!['h']!,
    ];

    List<List<int>> ts = [
      widget.times!['M']!,
      widget.times!['m']!,
      widget.times!['w']!,
      widget.times!['d']!,
      widget.times!['h']!,
    ];

    return DefaultTabController(
      length: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: veritcalPadding, horizontal: horizontalPadding),
            height: widget.height,
            child: PriceGraph(
              prices: ps[selected],
              times: ts[selected],
              horizontalPaddingParent: horizontalPadding,
              moving: _tabController!.indexIsChanging,
              // moving: false,
              lineColor: widget.color1,
              shadeColor: widget.color2,
              // pmin: pmin,
              // pmax: pmax
            ),
          ),
          Container(
            width: double.infinity,
            child: Center(
              child: Container(
                width: 200,
                height: 30,
                padding: EdgeInsets.only(bottom: 5, top: 2, left: 3, right: 3),
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
            ),
          ),
        ],
      ),
    );
  }
}

class PriceGraph extends StatefulWidget {
  final Array prices;
  final List<int> times;
  final bool? moving;
  final Color? lineColor;
  final Color? shadeColor;

  final double? horizontalPaddingParent;
  final double tPad = 0.05;
  final double bPad = 0.05;
  final double lPad = 0.05;
  final double rPad = 0.05;

  final double? pmin;
  final double? pmax;

  PriceGraph({
    required this.prices,
    required this.times,
    this.horizontalPaddingParent,
    this.moving,
    this.lineColor,
    this.shadeColor,
    this.pmin,
    this.pmax,
  });

  @override
  _PriceGraphState createState() => _PriceGraphState();
}

class _PriceGraphState extends State<PriceGraph> {
  // where has the user touched in the x-direction, in pixels?
  double? touchX;
  // what is the corresponding graph value at this location, in pixels?
  double? touchY;
  // what is the actual price at this location?
  double? priceY;
  // returns over user-sopecified period
  double? returns;

  PriceGraphPainter? priceChartPainter;
  double? graphWidth;
  double graphHeight = 200;

  // the min and max prices given
  double? pmin;
  double? pmax;
  double? lastp;

  // represents whether the prices are constant (in which case extra logic is needed for plotting)
  // bool isConstant;
  late intl.DateFormat dateFormat;
  String? dateX;

  // time difference between points
  // used to determine date format
  int? dt_t;

  @override
  void initState() {
    super.initState();
  }

  // floor time to nearest 15 mins/hour, given dt_t (code representing whcih way to do it)
  int formatTime(int t) {
    if (dt_t == 0) {
      return t;
    } else if (dt_t == 1) {
      return t - (t % 900);
    } else if (dt_t == 2) {
      return t - (t % 3600);
    } else {
      return t;
    }
  }

  /// given an x-coordinate in pixels, return an interpolated y-coordinate in currency
  double _pxToY(double? px) {
    if ((pmax! - pmin!).abs() < 1e-5) {
      return widget.prices.first;
    } else {
      // double equivelant of index number
      double i = (widget.prices.length - 1) * (px! / graphWidth! - widget.lPad) / (1 - widget.lPad - widget.rPad);
      if (i > (widget.prices.length - 1)) {
        // return last price
        return widget.prices.last;
      } else if (i < 0) {
        // return first price
        return widget.prices.first;
      } else {
        // interpolate
        return (1 - (i % 1)) * widget.prices[i.floor()] + (i % 1) * widget.prices[i.ceil()];
      }
    }
  }

  /// given an x-coordinate in pixels, return an interpolated y-coordinate in pixels
  double _pxToPy(double? px) {
    if ((pmax! - pmin!).abs() < 1e-5) {
      return graphHeight * ((1 - widget.tPad - widget.bPad) * 0.5 + widget.tPad);
    } else {
      return graphHeight * ((1 - widget.tPad - widget.bPad) * (1 - (_pxToY(px) - pmin!) / (pmax! - pmin!)) + widget.tPad);
    }
  }

  String unixToDateString(int t) {
    return dateFormat.format(DateTime.fromMillisecondsSinceEpoch(formatTime((1000 * t).floor())));
  }

  String _pxToDateX(double px) {
    double i = ((widget.prices.length - 1) * (px / graphWidth! - widget.lPad)) / (1 - widget.lPad - widget.rPad);
    if (i > (widget.prices.length - 1)) {
      return unixToDateString(widget.times.last);
    } else if (i < 0) {
      return unixToDateString(widget.times.first);
    } else {
      return unixToDateString(((1 - (i % 1)) * widget.times[i.floor()] + (i % 1) * widget.times[i.ceil()]).floor());
    }
  }

  void updateTouch(Offset localPosition) {
    setState(() {
      // we're further than the right edge of the graph so clip
      if (localPosition.dx > graphWidth! * (1 - widget.rPad)) {
        touchX = graphWidth! * (1 - widget.rPad);
      }
      // we're further than the left edge of the graph so clip
      else if (localPosition.dx < graphWidth! * widget.lPad) {
        touchX = graphWidth! * widget.lPad;
      }
      // all good
      else {
        touchX = localPosition.dx;
      }

      touchY = _pxToPy(touchX);
      priceY = _pxToY(touchX);
      dateX = _pxToDateX(touchX!);
    });
  }

  void setDateFormat(int dt) {
    dt_t = 0;

    if (dt < 2 * 3600) {
      dateFormat = intl.DateFormat('d MMM yy HH:mm');
      if (dt < 15 * 60) {
        dt_t = 0;
      } else if (dt < 3600) {
        dt_t = 1;
      } else {
        dt_t = 2;
      }
    } else if (dt < 24 * 3600) {
      dateFormat = intl.DateFormat('d MMM yy HH:00');
    } else {
      dateFormat = intl.DateFormat('d MMM yy');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (graphWidth == null) {
      graphWidth = MediaQuery.of(context).size.width - 2 * widget.horizontalPaddingParent!;
    }
    // check if all values in the price array are the same

    if (dt_t == null) {
      setDateFormat(widget.times[1] - widget.times[0]);
    }

    // we're switching tabs so reset some variables
    if (widget.moving!) {
      touchX = null;
      touchY = null;
      priceY = null;
      pmin = null;
      pmax = null;
      dateX = null;
      returns = null;
      dt_t = null;
    }

    if (pmin == null || widget.prices.last != lastp) {
      pmin = widget.prices.min;
      pmax = widget.prices.max;
      lastp = widget.prices.last;
    }

    if (widget.pmin != null) {
      pmin = widget.pmin;
      pmax = widget.pmax;
    }

    if (dateX == null) {
      dateX = unixToDateString((DateTime.now().millisecondsSinceEpoch / 1000).floor());
    }

    returns = (priceY ?? widget.prices.last) / widget.prices.first - 1;

    return Column(
      children: [
        Expanded(
          child: widget.moving!
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${unixToDateString(widget.times.first)} – \n$dateX',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15, color: Colors.grey[800]),
                    ),
                    // SizedBox(width: 15),
                    Center(
                        child: Text(
                      '${formatCurrency(widget.prices.first, 'GBP')} – ${formatCurrency(priceY ?? widget.prices.last, 'GBP')}',
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.grey[800]),
                    )),
                    // SizedBox(width: 15),
                    Text(
                      '${returns! >= 0 ? "+" : "-"}${formatPercentage(returns, 'GBP')}',
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 17, color: returns! >= 0 ? Colors.green : Colors.red),
                    ),
                    // SizedBox(height: 25),
                  ],
                ),
        ),
        GestureDetector(
          onTapDown: (TapDownDetails details) {
            if (!widget.moving!) {
              updateTouch(details.localPosition);
            }
          },
          onPanUpdate: (DragUpdateDetails details) {
            if (touchX != null && !widget.moving!) {
              updateTouch(details.localPosition);
            }
          },
          child: CustomPaint(
            size: Size(graphWidth!, graphHeight),
            painter: PriceGraphPainter(
              prices: widget.prices,
              touchX: touchX,
              touchY: touchY,
              // isConstant: isConstant,
              lineColor: widget.lineColor,
              shadeColor: widget.shadeColor,
              moving: widget.moving,
              tPad: widget.tPad,
              bPad: widget.bPad,
              lPad: widget.lPad,
              rPad: widget.rPad,
              pmin: pmin,
              pmax: pmax,
            ),
          ),
        ),
      ],
    );
  }
}

class PriceGraphPainter extends CustomPainter {
  final Array? prices;
  // final bool isConstant;
  final bool? moving;
  final Color? lineColor;
  final Color? shadeColor;
  final double? touchX;
  final double? touchY;
  final double? tPad;
  final double? bPad;
  final double? lPad;
  final double? rPad;

  int? n;
  late int xMax;
  late int xMin;
  double? pmin;
  double? pmax;
  int? cutOffIndex;

  PriceGraphPainter({
    this.prices,
    // this.isConstant,
    this.touchX,
    this.touchY,
    this.moving,
    this.lineColor,
    this.shadeColor,
    this.tPad,
    this.bPad,
    this.lPad,
    this.rPad,
    this.pmin,
    this.pmax,
  });

  double yToPy(double y, Size size) {
    return size.height * ((1 - tPad! - bPad!) * (1 - (y - pmin!) / (pmax! - pmin!)) + tPad!);
  }

  double xToPx(double x, Size size) {
    return x * ((1 - lPad! - rPad!) * size.width / (n! - 1)) + size.width * lPad!;
  }

  void paintPriceGrah(Size size, Canvas canvas, List<double?> pathX, List<double> pathY, double opacityMultiple) {
    Paint linePaint = Paint()
      ..color = lineColor!.withOpacity(opacityMultiple)
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
          shadeColor!.withOpacity(0.45 * opacityMultiple),
          shadeColor!.withOpacity(0.04 * opacityMultiple),
        ],
      );

    Path graphLine = Path();
    Path shading = Path();

    int pathLength = pathX.length;

    graphLine.moveTo(pathX[0]!, pathY[0]);
    shading.moveTo(pathX[0]!, pathY[0]);

    for (int i = 1; i < pathLength; i++) {
      if (i < pathLength - 3) {
        graphLine.lineTo(pathX[i]!, pathY[i]);
      }
      shading.lineTo(pathX[i]!, pathY[i]);
    }

    canvas.drawPath(graphLine, linePaint);
    canvas.drawPath(shading, shadePaint);
  }

  void paintTouchLine(Size size, Canvas canvas) {
    Path touchLine = Path();

    touchLine.moveTo(touchX!, size.height * tPad!);

    for (int i in range(20)) {
      double h1 = size.height * tPad! + (2 * i / 40) * size.height * (1 - bPad!);
      double h2 = size.height * tPad! + (((2 * i) + 1) / 40) * size.height * (1 - bPad!);
      touchLine.lineTo(touchX!, h1);
      touchLine.moveTo(touchX!, h2);
    }

    Paint touchLinePaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(touchLine, touchLinePaint);
  }

  void paintPriceText(Size size, Canvas canvas, String minOrMax) {
    TextSpan priceText = TextSpan(
      text: formatCurrency(minOrMax == 'min' ? pmin : pmax, 'GBP'),
      style: TextStyle(color: Colors.grey[850], fontSize: 12, fontWeight: FontWeight.w400),
    );

    TextPainter pricePainter = TextPainter(text: priceText, textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    pricePainter.layout(minWidth: 0, maxWidth: 60);

    pricePainter.paint(
        canvas,
        minOrMax == 'min'
            ? Offset(
                xToPx(xMin + 0.0, size) - pricePainter.width / 2,
                yToPy(pmin!, size) + 5,
              )
            : Offset(
                xToPx(xMax + 0.0, size) - pricePainter.width / 2,
                yToPy(pmax!, size) - pricePainter.height - 2,
              ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    //

    n = prices!.length;
    xMax = range(n).reduce((prev, cur) => prices![prev] > prices![cur] ? prev : cur);
    xMin = range(n).reduce((prev, cur) => prices![prev] < prices![cur] ? prev : cur);
    if (pmin == null) {
      pmin = prices![xMin];
      pmax = prices![xMax];
    }

    bool isConstant = ((pmin! - pmax!).abs() < 1e-5);

    // calculate cut-off index
    if (touchX != null) {
      cutOffIndex = (((prices!.length - 1) * (touchX! / size.width - lPad!)) / (1 - lPad! - rPad!)).ceil();
    }

    double y0 = (1 - bPad!) * size.height;
    double x0 = size.width * lPad!;
    double x1 = (1 - lPad! - rPad!) * size.width + size.width * lPad!;

    // constant graph
    if (isConstant) {
      double y1 = ((1 - tPad! - bPad!) * 0.5 + tPad!) * size.height;

      // single line
      if (touchX == null) {
        paintPriceGrah(size, canvas, [x0, x1, x1, x0, x0], [y1, y1, y0, y0, y1], 1);
      }
      // two halves
      else {
        paintPriceGrah(size, canvas, <double>[x0, touchX!, touchX!, x0, x0], <double>[y1, y1, y0, y0, y1], 1);
        paintPriceGrah(size, canvas, <double>[touchX!, x1, x1, touchX!, touchX!], <double>[y1, y1, y0, y0, y1], 0.3);
      }
    }
    // normal graph
    else {
      // basic x-y coordinates
      List pathpY = prices!.apply((double y) => yToPy(y, size)).toList();
      List pathpX = List<double>.generate(n!, (x) => xToPx(x + 0.0, size));

      // single graph
      if (touchX == null) {
        paintPriceGrah(
          size,
          canvas,
          pathpX + <double>[x1, x0, x0] as List<double>,
          pathpY + <double>[y0, y0, pathpY.first] as List<double>,
          1,
        );
      }
      // two halves
      else {
        // first half
        paintPriceGrah(
          size,
          canvas,
          pathpX.sublist(0, cutOffIndex) + <double>[touchX!, touchX!, x0, x0] as List<double>,
          pathpY.sublist(0, cutOffIndex) + <double>[touchY!, y0, y0, pathpY.first] as List<double>,
          1,
        );
        // second half
        paintPriceGrah(
          size,
          canvas,
          <double>[touchX!] + (pathpX.sublist(cutOffIndex!) as List<double>) + <double>[x1, touchX!, touchX!],
          <double>[touchY!] + (pathpY.sublist(cutOffIndex!) as List<double>) + <double>[y0, y0, touchY!],
          0.3,
        );
      }
    }

    // paint on touch line
    if (touchX != null) {
      paintTouchLine(size, canvas);
    }

    // paint on min and max prices
    if (!isConstant && !moving!) {
      paintPriceText(size, canvas, 'min');
      paintPriceText(size, canvas, 'max');
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => this.moving!;
}
