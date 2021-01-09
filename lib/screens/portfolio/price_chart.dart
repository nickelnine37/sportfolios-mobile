import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data_models/portfolios.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:sportfolios_alpha/utils/axis_range.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

class TabbedPriceGraph extends StatelessWidget {

  final Portfolio portfolio;
  const TabbedPriceGraph({@required this.portfolio});


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            //Add this to give height
            height: 200,
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Container(
                  height: 250,
                  width: 200,
                  child: Center(child: PriceGraph(prices: this.portfolio.contracts[0].pH)),
                ),
                Container(
                  child: Center(child: PriceGraph(prices: this.portfolio.contracts[0].pD)),
                ),
                Container(
                  child: Center(child: PriceGraph(prices: this.portfolio.contracts[0].pW)),
                ),
                Container(
                  child: Center(child: PriceGraph(prices: this.portfolio.contracts[0].pM)),
                ),
                Container(
                  child: Center(child: PriceGraph(prices: this.portfolio.contracts[0].pMax)),
                ),
              ],
            ),
          ),
          Container(
            width: 200,
            height: 30,
            padding: EdgeInsets.only(bottom: 5, top: 2, left: 3, right: 3),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(
                  color: Colors.grey[500],
                  width: 1,
                )),
            child: TabBar(
              labelPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(
                    child: Text(
                  '1h',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                )),
                Tab(
                    child: Text(
                  '1d',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                )),
                Tab(
                    child: Text(
                  '1w',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                )),
                Tab(
                    child: Text(
                  '1M',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                )),
                Tab(
                    child: Text(
                  'Max',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PriceGraph extends StatefulWidget {
  final List<double> prices;
  final double tPad = 0.05;
  final double bPad = 0.05;
  final double lPad = 0.2;
  final double rPad = 0;
  final double yaxisPadT = 0.05;
  final double yaxisPadB = 0.08;
  final double xaxisPadR = 0.05;

  PriceGraph({this.prices});

  @override
  _PriceGraphState createState() => _PriceGraphState();
}

class _PriceGraphState extends State<PriceGraph> {
  double touchX;
  double touchY;
  MiniPriceChartPainter priceChartPainter;
  double width;
  double height = 200;
  double pmin;
  double pmax;
  double priceY;

  @override
  void initState() {
    priceChartPainter = MiniPriceChartPainter(
      prices: widget.prices,
      tPad: widget.tPad,
      bPad: widget.bPad,
      lPad: widget.lPad,
      rPad: widget.rPad,
      yaxisPadT: widget.yaxisPadT,
      yaxisPadB: widget.yaxisPadB,
      xaxisPadR: widget.xaxisPadR,
    );
    super.initState();
  }

  double _pxToY(px) {
    // given an x-coordinate in pixels, return an interpolated y-coordinate in currency
    double i = ((widget.prices.length - 1) * (px / width - widget.lPad)) /
        (1 - widget.lPad - widget.rPad - widget.xaxisPadR);
    if (i > (widget.prices.length - 1)) {
      return widget.prices[widget.prices.length - 1];
    } else if (i < 0) {
      return widget.prices[0];
    } else {
      return (1 - (i % 1)) * widget.prices[i.floor()] +
          (i % 1) * widget.prices[i.ceil()];
    }
  }

  double _pxToPy(px) {
    // given an x-coordinate in pixels, return an interpolated y-coordinate in pixels
    return height *
        ((1 - widget.tPad - widget.yaxisPadT - widget.bPad - widget.yaxisPadB) *
                (1 - (_pxToY(px) - pmin) / (pmax - pmin)) +
            widget.tPad +
            widget.yaxisPadT);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width * 0.7;
    if (pmin == null) {
      pmin = widget.prices.reduce(min);
      pmax = widget.prices.reduce(max);
    }


    return Row(children: [
      GestureDetector(
        onTapDown: (details) {
          setState(() {
            if (details.localPosition.dx >
                width * (1 - widget.rPad - widget.xaxisPadR)) {
              touchX = width * (1 - widget.rPad - widget.xaxisPadR);
            } else if (details.localPosition.dx < width * widget.lPad) {
              touchX = width * widget.lPad;
            } else {
              touchX = details.localPosition.dx;
            }
            touchY = _pxToPy(details.localPosition.dx);
            priceY = _pxToY(details.localPosition.dx);
          });
        },
        onPanUpdate: (details) {
          if (touchX != null) {
            setState(() {
              if (details.localPosition.dx >
                  width * (1 - widget.rPad - widget.xaxisPadR)) {
                touchX = width * (1 - widget.rPad - widget.xaxisPadR);
              } else if (details.localPosition.dx < width * widget.lPad) {
                touchX = width * widget.lPad;
              } else {
                touchX = details.localPosition.dx;
              }
              touchY = _pxToPy(details.localPosition.dx);
              priceY = _pxToY(details.localPosition.dx);
            });
          }
        },
        child: Stack(
          children: [
            CustomPaint(
              size: Size(width, height),
              painter: TouchLinePainter(
                touchX,
                touchY,
                tPad: widget.tPad,
                bPad: widget.bPad,
              ),
            ),
            CustomPaint(
              size: Size(width, height),
              painter: priceChartPainter,
            ),
          ],
        ),
      ),
      Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(formatCurrency(priceY ?? 0, 'GBP'),
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                    color: Colors.grey[800],
                  )))
        ],
      ))
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

class MiniPriceChartPainter extends CustomPainter {
  List<double> prices;
  final double tPad;
  final double bPad;
  final double lPad;
  final double rPad;
  final double yaxisPadT;
  final double yaxisPadB;
  final double xaxisPadR;

  MiniPriceChartPainter(
      {this.prices,
      this.tPad,
      this.bPad,
      this.lPad,
      this.rPad,
      this.yaxisPadT,
      this.yaxisPadB,
      this.xaxisPadR});

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Paint shadePaint = Paint()
      // ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..strokeWidth = 0
      ..shader = ui.Gradient.linear(
        Offset(100, 0),
        Offset(100, 180),
        [
          Colors.green[800].withOpacity(0.45),
          Colors.green[800].withOpacity(0.04),
        ],
      );

    Paint axisPaint = Paint()
      ..color = Colors.grey[600]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // Paint axisTickPaint = Paint()..color = Colors.grey[600] .. style = PaintingStyle.stroke .. strokeWidth = 1;

    int N = prices.length;
    double pmin = prices.reduce(min);
    double pmax = prices.reduce(max);

    List ticks = getAxisTicks(pmin, pmax);

    double yToPy(y) {
      return size.height *
          ((1 - tPad - yaxisPadT - bPad - yaxisPadB) *
                  (1 - (y - pmin) / (pmax - pmin)) +
              tPad +
              yaxisPadT);
    }

    double xToPx(x) {
      // TODO: fix this x-direction stuff
      return x * ((1 - lPad - rPad - xaxisPadR) * size.width / (N - 1)) +
          size.width * lPad;
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
          [
            size.width * (1 - rPad - xaxisPadR),
            size.width * lPad,
            size.width * lPad
          ];
    }

    List pathpY = mapY();
    List pathpX = mapX();

    Path line = Path();
    Path shading = Path();
    Path yaxis = Path();
    Path xaxis = Path();

    line.moveTo(pathpX[0], pathpY[0]);
    shading.moveTo(pathpX[0], pathpY[0]);

    for (int i = 0; i < N + 3; i++) {
      if (i < N) {
        line.lineTo(pathpX[i], pathpY[i]);
      }
      shading.lineTo(pathpX[i], pathpY[i]);
    }

    for (int i = 0; i < ticks.length; i++) {
      double pY = yToPy(ticks[i]);

      if (pY > tPad * size.height && pY < (1 - bPad) * size.height) {
        TextPainter textPainter = TextPainter(
            text: TextSpan(
              text: formatCurrency(ticks[i], 'GBP'),
              style: TextStyle(
                color: Colors.grey[850],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);

        textPainter.layout(minWidth: 0, maxWidth: 60);
        textPainter.paint(
            canvas,
            Offset(lPad * size.width, pY) -
                Offset(textPainter.width + 7, (textPainter.height / 2)));

        yaxis.moveTo(lPad * size.width - 3, pY);
        yaxis.lineTo(lPad * size.width + 3, pY);
      }
    }

    yaxis.moveTo(lPad * size.width, tPad * size.height);
    yaxis.lineTo(lPad * size.width, (1 - bPad) * size.height);

    xaxis.moveTo(lPad * size.width, (1 - bPad) * size.height);
    xaxis.lineTo((1 - rPad) * size.width, (1 - bPad) * size.height);

    canvas.drawPath(line, linePaint);
    canvas.drawPath(shading, shadePaint);
    canvas.drawPath(yaxis, axisPaint);
    canvas.drawPath(xaxis, axisPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
