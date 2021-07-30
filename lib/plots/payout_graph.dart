import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sportfolios_alpha/utils/numerical/arrays.dart';
import '../utils/numerical/array_operations.dart';
import '../utils/strings/number_format.dart';
import '../utils/strings/string_utils.dart';

class PayoutGraph extends StatefulWidget {
  final Array q;
  final double padding;
  final double height;
  final bool tappable;
  final double pmax;

  PayoutGraph({required this.q, required this.tappable, this.padding = 25, this.height = 150, this.pmax=10});

  @override
  _PayoutGraphState createState() => _PayoutGraphState();
}

class _PayoutGraphState extends State<PayoutGraph> {
  int? selectedBar;
  int? n;
  double? width;

  List<CustomPaint> _rereshPainters() {
    if (selectedBar == null) {
      return range(n)
          .map(
            (int i) => CustomPaint(
              painter: SimpleBar(payouts: widget.q, index: i, opacity: 1, pmax: widget.pmax),
              size: Size(width!, widget.height),
            ),
          )
          .toList();
    } else {
      return range(n)
          .map(
            (int i) => CustomPaint(
              painter: SimpleBar(payouts: widget.q, index: i, opacity: (i == selectedBar) ? 1 : 0.5, pmax: widget.pmax),
              size: Size(width!, widget.height),
            ),
          )
          .toList();
    }
  }

  int? _selectedBar(Offset touchLocation) {
    int selected = (n! * touchLocation.dx / width!).floor();

    if (touchLocation.dy + 20 > widget.height - widget.height * widget.q[selected] / widget.pmax)
      return selected;
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    if (n == null) {
      n = widget.q.length;
    }

    if (width == null) {
      width = MediaQuery.of(context).size.width - 2 * widget.padding;
    }

    if (!widget.tappable) {
      selectedBar = null;
    }

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 20,
              child: Text(
                selectedBar != null
                    ? '${widget.q.length - selectedBar!}${formatOrdinal(widget.q.length - selectedBar!)} place payout: ${formatCurrency(widget.q[selectedBar!], 'GBP')}'
                    : 'Payout Structure',
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
            ),
          ),
          widget.tappable
              ? GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    int? newSelectedBar = _selectedBar(details.localPosition);
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
                      children: _rereshPainters(),
                    ),
                  ),
                )
              : Shimmer.fromColors(
                  baseColor: Colors.blue,
                  highlightColor: Colors.blue.withAlpha(150),
                  period: Duration(milliseconds: 3000),
                  enabled: !widget.tappable,
                  child: Container(
                    alignment: Alignment.topRight,
                    width: width,
                    height: widget.height,
                    child: Stack(
                      children: _rereshPainters(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class SimpleBar extends CustomPainter {
  Array payouts;
  int index;
  double opacity;
  double pmax;

  SimpleBar({required this.payouts, required this.index, this.opacity = 1, this.pmax = 10});

  @override
  void paint(Canvas canvas, Size size) {
    int n = payouts.length;
    double barWidth = 0.95 * size.width / n;
    double barHeight = payouts[index] * size.height / pmax;

    Paint paint = Paint()..color = Colors.blue.withOpacity(opacity * (0.4 + 0.6 * payouts[index] / pmax));

    TextSpan positionText = TextSpan(
        text: (payouts.length - index).toString(),
        style: TextStyle(color: Colors.grey[850]!.withOpacity(opacity), fontSize: 11, fontWeight: FontWeight.w400));

    TextPainter positionTextPainter = TextPainter(text: positionText, textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    positionTextPainter.layout(minWidth: 0, maxWidth: 60);

    positionTextPainter.paint(canvas, Offset((index + 0.5) * size.width / n - positionTextPainter.width / 2, size.height));

    canvas.drawRect(Rect.fromLTWH(index * size.width / n, size.height - barHeight, barWidth, barHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
