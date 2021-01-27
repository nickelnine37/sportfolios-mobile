import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:sportfolios_alpha/utils/number_format.dart';

class TabbedPriceGraph extends StatefulWidget {
  final Instrument instrument;
  final Color color1;
  final Color color2;

  const TabbedPriceGraph({@required this.instrument, this.color1 = Colors.green, this.color2 = Colors.green});

  @override
  _TabbedPriceGraphState createState() => _TabbedPriceGraphState();
}

class _TabbedPriceGraphState extends State<TabbedPriceGraph> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.instrument);
    return DefaultTabController(
      length: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            //Add this to give height
            height: 200,
            child: AnimatedBuilder(
              animation: _tabController.animation,
              builder: (BuildContext context, snapshot) {
                int g1 = _tabController.previousIndex;
                int g2 = _tabController.index;
                double pcComplete = (g1 == g2) ? 0 : (_tabController.animation.value - g1) / (g2 - g1);

                List<List<double>> ps = [
                  this.widget.instrument.pH,
                  this.widget.instrument.pD,
                  this.widget.instrument.pW,
                  this.widget.instrument.pM,
                  this.widget.instrument.pMax
                ];

                return PriceGraph(
                  prices: matrixMultiply([ps[g1], ps[g2]], [1 - pcComplete, pcComplete]),
                  moving: _tabController.indexIsChanging,
                  color1: widget.color1,
                  color2: widget.color2,
                );
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Center(
              child: Container(
                width: 200,
                height: 30,
                padding: EdgeInsets.only(bottom: 5, top: 2, left: 3, right: 3),
                // decoration: BoxDecoration(
                //   color: Colors.black.withOpacity(0.05),
                //   borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //   border: Border.all(
                //     color: Colors.grey[500],
                //     width: 1,
                //   ),
                // ),
                child: TabBar(
                  controller: _tabController,
                  labelPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(child: Text('1h', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                    Tab(child: Text('1d', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                    Tab(child: Text('1w', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                    Tab(child: Text('1M', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                    Tab(child: Text('Max', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
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
  final List<double> prices;
  final bool moving;
  final Color color1;
  final Color color2;

  final double tPad = 0.05;
  final double bPad = 0.05;
  final double lPad = 0.08;
  final double rPad = 0;
  final double yaxisPadT = 0;
  final double yaxisPadB = 0.08;
  final double xaxisPadR = 0.05;

  PriceGraph({this.prices, this.moving, this.color1, this.color2});

  @override
  _PriceGraphState createState() => _PriceGraphState();
}

class _PriceGraphState extends State<PriceGraph> {
  double touchX;
  double touchY;
  PriceGraphPainter priceChartPainter;
  double graphWidth;
  double height = 200;
  double pmin;
  double pmax;
  double priceY;
  double portfolioInit;
  bool isConstant;

  @override
  void initState() {
    super.initState();
    portfolioInit = widget.prices[0];
  }

  /// given an x-coordinate in pixels, return an interpolated y-coordinate in currency
  double _pxToY(px) {
    if (isConstant) {
      return widget.prices[0];
    } else {
      double i = ((widget.prices.length - 1) * (px / graphWidth - widget.lPad)) /
          (1 - widget.lPad - widget.rPad - widget.xaxisPadR);
      if (i > (widget.prices.length - 1)) {
        return widget.prices[widget.prices.length - 1];
      } else if (i < 0) {
        return widget.prices[0];
      } else {
        return (1 - (i % 1)) * widget.prices[i.floor()] + (i % 1) * widget.prices[i.ceil()];
      }
    }
  }

  /// given an x-coordinate in pixels, return an interpolated y-coordinate in pixels
  double _pxToPy(px) {
    if (isConstant) {
      return height *
          ((1 - widget.tPad - widget.yaxisPadT - widget.bPad - widget.yaxisPadB) * 0.5 +
              widget.tPad +
              widget.yaxisPadT);
    } else {
      return height *
          ((1 - widget.tPad - widget.yaxisPadT - widget.bPad - widget.yaxisPadB) *
                  (1 - (_pxToY(px) - pmin) / (pmax - pmin)) +
              widget.tPad +
              widget.yaxisPadT);
    }
  }

  @override
  Widget build(BuildContext context) {
    // check if all values in the price array are the same
    isConstant = widget.prices.every((element) => element == widget.prices[0]);

    // we're switching tabs so reset some variables
    if (widget.moving) {
      touchX = null;
      touchY = null;
      priceY = null;
      pmin = null;
    }

    // this is a dumb hacky way of checking whether we've just switched portfolios
    // in which case, we need to reset all of the touch variables.
    if (portfolioInit != null) {
      if (portfolioInit != widget.prices[0]) {
        touchX = null;
        touchY = null;
        priceY = null;
        pmin = null;
      }
      portfolioInit = widget.prices[0];
    }

    graphWidth = MediaQuery.of(context).size.width * 0.7;

    if (pmin == null) {
      pmin = widget.prices.reduce(min);
      pmax = widget.prices.reduce(max);
    }

    return Row(children: [
      GestureDetector(
        onTapDown: (details) {
          if (!widget.moving) {
            setState(() {
              // we're further than the right edge of the graph so clip
              if (details.localPosition.dx > graphWidth * (1 - widget.rPad - widget.xaxisPadR))
                touchX = graphWidth * (1 - widget.rPad - widget.xaxisPadR);
              // we're further than the left edge of the graph so clip
              else if (details.localPosition.dx < graphWidth * widget.lPad)
                touchX = graphWidth * widget.lPad;
              // all good
              else
                touchX = details.localPosition.dx;

              touchY = _pxToPy(touchX);
              priceY = _pxToY(touchX);
            });
          }
        },
        onPanUpdate: (details) {
          if (touchX != null && !widget.moving) {
            setState(() {
              // we're further than the right edge of the graph so clip
              if (details.localPosition.dx > graphWidth * (1 - widget.rPad - widget.xaxisPadR))
                touchX = graphWidth * (1 - widget.rPad - widget.xaxisPadR);
              // we're further than the left edge of the graph so clip
              else if (details.localPosition.dx < graphWidth * widget.lPad)
                touchX = graphWidth * widget.lPad;
              // all good
              else
                touchX = details.localPosition.dx;

              touchY = _pxToPy(touchX);
              priceY = _pxToY(touchX);
            });
          }
        },
        child: Stack(
          children: [
            CustomPaint(
              size: Size(graphWidth, height),
              painter: TouchLinePainter(
                touchX,
                touchY,
                tPad: widget.tPad,
                bPad: widget.bPad,
              ),
            ),
            Consumer(builder: (context, watch, value) {
              String currency = watch(settingsProvider).currency;

              return CustomPaint(
                size: Size(graphWidth, height),
                painter: PriceGraphPainter(
                  prices: widget.prices,
                  isConstant: isConstant,
                  color1: widget.color1,
                  color2: widget.color2,
                  moving: widget.moving,
                  currency: currency,
                  tPad: widget.tPad,
                  bPad: widget.bPad,
                  lPad: widget.lPad,
                  rPad: widget.rPad,
                  yaxisPadT: widget.yaxisPadT,
                  yaxisPadB: widget.yaxisPadB,
                  xaxisPadR: widget.xaxisPadR,
                ),
              );
            })
          ],
        ),
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(builder: (context, watch, value) {
              String currency = watch(settingsProvider).currency;
              return Center(
                child: Text(
                  '${widget.moving ? '' : formatCurrency(priceY ?? widget.prices.last, currency)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                    color: Colors.grey[800],
                  ),
                ),
              );
            })
          ],
        ),
      )
    ]);
  }
}

class TouchLinePainter extends CustomPainter {
  double touchX;
  double touchY;
  final double tPad;
  final double bPad;

  TouchLinePainter(
    this.touchX,
    this.touchY, {
    this.tPad,
    this.bPad,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (this.touchX == null) {
      return;
    }

    Paint linePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = ui.Gradient.radial(Offset(touchX, touchY), size.height / 2.5, [
        Colors.grey[800].withOpacity(0.8),
        Colors.grey[800].withOpacity(0),
      ]);
    Paint circlePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Path line = Path();

    line.moveTo(this.touchX, size.height * this.tPad);
    line.lineTo(this.touchX, size.height * (1 - this.bPad));

    canvas.drawPath(line, linePaint);
    canvas.drawCircle(Offset(touchX, touchY), 3, circlePaint);
  }

  @override
  bool shouldRepaint(TouchLinePainter oldDelegate) => true;
}

class PriceGraphPainter extends CustomPainter {
  List<double> prices;
  bool isConstant;
  bool moving;
  String currency;
  Color color1;
  Color color2;
  final double tPad;
  final double bPad;
  final double lPad;
  final double rPad;
  final double yaxisPadT;
  final double yaxisPadB;
  final double xaxisPadR;

  PriceGraphPainter({
    this.prices,
    this.isConstant,
    this.moving,
    this.currency,
    this.color1,
    this.color2,
    this.tPad,
    this.bPad,
    this.lPad,
    this.rPad,
    this.yaxisPadT,
    this.yaxisPadB,
    this.xaxisPadR,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = color1
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    Paint shadePaint = Paint()
      // ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..strokeWidth = 0
      ..shader = ui.Gradient.linear(
        Offset(100, 0),
        Offset(100, 180),
        [
          color2.withOpacity(0.45),
          color2.withOpacity(0.04),
        ],
      );

    Path line = Path();
    Path shading = Path();

    if (isConstant) {
      double y = ((1 - tPad - yaxisPadT - bPad - yaxisPadB) * 0.5 + tPad + yaxisPadT) * size.height;
      double y0 = (1 - bPad) * size.height;

      double x0 = size.width * lPad;
      double x1 = (1 - lPad - rPad - xaxisPadR) * size.width + size.width * lPad;

      line.moveTo(x0, y);
      line.lineTo(x1, y);

      shading.moveTo(x0, y);
      shading.lineTo(x1, y);
      shading.lineTo(x1, y0);
      shading.lineTo(x0, y0);
      shading.lineTo(x0, y);
    } else {
      int N = prices.length;
      int xMax = range(N).reduce((prev, cur) => prices[prev] > prices[cur] ? prev : cur);
      int xMin = range(N).reduce((prev, cur) => prices[prev] < prices[cur] ? prev : cur);
      double pmin = prices[xMin];
      double pmax = prices[xMax];

      double yToPy(y) {
        return size.height *
            ((1 - tPad - yaxisPadT - bPad - yaxisPadB) * (1 - (y - pmin) / (pmax - pmin)) + tPad + yaxisPadT);
      }

      double xToPx(x) {
        // TODO: fix this x-direction stuff
        return x * ((1 - lPad - rPad - xaxisPadR) * size.width / (N - 1)) + size.width * lPad;
      }

      List mapY() {
        return prices.map((y) => yToPy(y)).toList() +
            [
              (1 - bPad) * size.height,
              (1 - bPad) * size.height,
              yToPy(prices[0]),
            ];
      }

      List mapX() {
        return List.generate(N, (x) => xToPx(x)) +
            [size.width * (1 - rPad - xaxisPadR), size.width * lPad, size.width * lPad];
      }

      List pathpY = mapY();
      List pathpX = mapX();

      line.moveTo(pathpX[0], pathpY[0]);
      shading.moveTo(pathpX[0], pathpY[0]);

      for (int i = 0; i < N + 3; i++) {
        if (i < N) {
          line.lineTo(pathpX[i], pathpY[i]);
        }
        shading.lineTo(pathpX[i], pathpY[i]);
      }

      if (!moving) {
        TextSpan minPriceText = TextSpan(
          text: formatCurrency(pmin, this.currency),
          style: TextStyle(color: Colors.grey[850], fontSize: 12, fontWeight: FontWeight.w400),
        );

        TextSpan maxPriceText = TextSpan(
          text: formatCurrency(pmax, this.currency),
          style: TextStyle(color: Colors.grey[850], fontSize: 12, fontWeight: FontWeight.w400),
        );

        TextPainter minPricePainter =
            TextPainter(text: minPriceText, textDirection: TextDirection.ltr, textAlign: TextAlign.center);

        TextPainter maxPricePainter =
            TextPainter(text: maxPriceText, textDirection: TextDirection.ltr, textAlign: TextAlign.center);

        minPricePainter.layout(minWidth: 0, maxWidth: 60);
        maxPricePainter.layout(minWidth: 0, maxWidth: 60);

        minPricePainter.paint(
          canvas,
          Offset(
            xToPx(xMin) - minPricePainter.width / 2,
            yToPy(pmin) + 2,
          ),
        );
        maxPricePainter.paint(
          canvas,
          Offset(
            xToPx(xMax) - maxPricePainter.width / 2,
            yToPy(pmax) - maxPricePainter.height - 2,
          ),
        );
      }
    }

    canvas.drawPath(line, linePaint);
    canvas.drawPath(shading, shadePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => this.moving;
}
