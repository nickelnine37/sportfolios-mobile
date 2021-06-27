import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:confetti/confetti.dart';

import '../../data/api/requests.dart';
import '../../data/objects/markets.dart';
import '../../plots/payout_graph.dart';
import '../../utils/numerical/array_operations.dart';
import '../../utils/strings/number_format.dart';
import '../../data/objects/portfolios.dart';

class SellMarket extends StatefulWidget {
  final Market market;
  final List<double> quantityHeld;
  final Portfolio portfolio;

  SellMarket(this.portfolio, this.market, this.quantityHeld);

  @override
  _SellMarketState createState() => _SellMarketState();
}

class _SellMarketState extends State<SellMarket> {
  Future<void> _marketFuture;
  List<double> qHeldNew;
  bool locked = false;
  double lrPadding = 25;
  double graphWidth;
  double graphHeight = 150;
  double pmax;

  @override
  void initState() {
    super.initState();
    _marketFuture = widget.market.lmsr.updateCurrentX();
  }

  void updateHistory() {
    // .priceTrade(range(widget.market.n).map((int i) => qHeldNew[i] - widget.quantityHeld[i]).toList(), 1));
  }

  void _makeSelection(Offset touchLocation) {
    int x = (widget.market.lmsr.n * touchLocation.dx / graphWidth).floor();
    if (x < 0) {
      x = 0;
    } else if (x > widget.market.lmsr.n - 1) {
      x = widget.market.lmsr.n - 1;
    }
    double y = pmax * (1 - (touchLocation.dy - 20) / (graphHeight + 20));

    if (y < 0) {
      y = 0;
    }
    if (y > widget.quantityHeld[x]) {
      y = widget.quantityHeld[x];
    }
    List<double> qHeldNew_ = range(widget.market.lmsr.n).map((int i) => i == x ? y : qHeldNew[i]).toList();

    if (qHeldNew != qHeldNew_) {
      setState(() {
        qHeldNew = qHeldNew_;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (graphWidth == null) {
      graphWidth = MediaQuery.of(context).size.width - 2 * lrPadding;
    }

    if (pmax == null) {
      pmax = getMax(widget.quantityHeld);
    }

    if (qHeldNew == null) {
      qHeldNew = widget.quantityHeld;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 520,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
          ),
        ),
        child: Container(
          child: Padding(
            padding: EdgeInsets.only(left: 35, right: 35, bottom: 10),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: CustomPaint(painter: SwipeDownTopBarPainter())),
                SizedBox(height: 5),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text('Sell: ${widget.market.name}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300)),
                        SizedBox(height: 5),
                        Divider(thickness: 2, height: 25),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CachedNetworkImage(
                                imageUrl: widget.market.imageURL,
                                height: 50,
                              ),
                              Column(
                                children: [
                                  Text('Total value'),
                                  SizedBox(height: 3),
                                  Text(
                                    formatCurrency(-widget.market.lmsr.priceTrade(widget.quantityHeld, -1), 'GBP'),
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('Payout date'),
                                  SizedBox(height: 3),
                                  Text(
                                    intl.DateFormat.yMMMd().format(widget.market.endDate),
                                    // TODO: add market expirey date
                                    // DateFormat('d MMM yy').format(widget.league.endDate),
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            ]),
                        Divider(thickness: 2, height: 25),
                        Row(
                          children: [
                            Switch(
                              value: locked,
                              onChanged: (bool val) {
                                setState(() {
                                  locked = val;
                                });
                              },
                            ),
                            Text('Lock payout')
                          ],
                        ),
                        locked
                            ? TrueStaticPayoutGraph(qHeldNew, Colors.blue, lrPadding, graphHeight, true, pmax)
                            : GestureDetector(
                                child: TrueStaticPayoutGraph(
                                    qHeldNew, Colors.blue, lrPadding, graphHeight, false, pmax),
                                onVerticalDragStart: (DragStartDetails details) {
                                  _makeSelection(details.localPosition);
                                },
                                onVerticalDragUpdate: (DragUpdateDetails details) {
                                  _makeSelection(details.localPosition);
                                },
                                onTapDown: (TapDownDetails details) {
                                  _makeSelection(details.localPosition);
                                },
                                onPanUpdate: (DragUpdateDetails details) {
                                  _makeSelection(details.localPosition);
                                },
                                onPanEnd: (DragEndDetails details) {
                                  setState(() {
                                    updateHistory();
                                  });
                                },
                                onTapUp: (TapUpDetails details) {
                                  setState(() {
                                    updateHistory();
                                  });
                                },
                                onVerticalDragEnd: (DragEndDetails details) {
                                  setState(() {
                                    updateHistory();
                                  });
                                },
                              ),
                        SizedBox(height: 25),
                        FutureBuilder(
                          future: _marketFuture,
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return SellForm(
                                  widget.portfolio,
                                  widget.market,
                                  range(widget.market.lmsr.n)
                                      .map((int i) => qHeldNew[i] - widget.quantityHeld[i])
                                      .toList());
                            } else if (snapshot.hasError) {
                              print(snapshot.error);
                              return Center(child: Text('Error'));
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SellForm extends StatefulWidget {
  final Portfolio portfolio;
  final Market market;
  final List<double> quantity;

  SellForm(this.portfolio, this.market, this.quantity);

  @override
  _SellFormState createState() => _SellFormState();
}

class _SellFormState extends State<SellForm> {
  double payout;
  bool loading = false;
  bool complete = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    payout = widget.market.lmsr.priceTrade(widget.quantity, 1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payout:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              Text(
                formatCurrency(payout.abs(), 'GBP'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              FlatButton(
                child: loading
                    ? Container(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ))
                    : complete
                        ? Icon(Icons.done, color: Colors.white)
                        : Text('OK', style: TextStyle(color: Colors.white)),
                color: Colors.blue,
                onPressed: () async {
                  if (!complete) {
                    setState(() {
                      loading = true;
                    });

                    Map<String, dynamic> purchaseRequestResult = await makePurchaseRequest(
                        widget.market.id, widget.portfolio.id, widget.quantity, payout + 1);

                    await Future.delayed(Duration(seconds: 1));

                    if (purchaseRequestResult['success']) {
                      setState(() {
                        loading = false;
                        complete = true;
                      });

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PurchaseCompletePopup();
                          });

                      await Future.delayed(Duration(milliseconds: 800));
                      Navigator.of(context).pop();

                      await Future.delayed(Duration(milliseconds: 500));

                      Navigator.of(context).pop(true);

                    } else {
                      setState(() {
                        loading = false;
                        complete = false;
                      });

                      bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ConfirmPurchase(
                                    oldPrice: payout, newPrice: purchaseRequestResult['price']);
                              }) ??
                          false;

                      bool ok = await respondToNewPrice(
                        confirm,
                        purchaseRequestResult['cancelId'],
                        widget.market.id,
                        widget.portfolio.id,
                        widget.quantity,
                        purchaseRequestResult['price'],
                      );

                      if (confirm && !ok) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ProblemPopup();
                            });
                        await Future.delayed(Duration(seconds: 1));
                        Navigator.of(context).pop(false);
                      } else if (confirm && ok) {
                        setState(() {
                          payout = purchaseRequestResult['price'];
                          loading = false;
                          complete = true;
                        });

                        await Future.delayed(Duration(milliseconds: 600));
                        Navigator.of(context).pop(true);
                      } else if (!confirm) {
                        await Future.delayed(Duration(milliseconds: 600));
                        Navigator.of(context).pop(false);
                      }
                    }
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class PurchaseCompletePopup extends StatelessWidget {
  const PurchaseCompletePopup({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double padding = 30;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
          height: 90,
          padding: EdgeInsets.only(top: padding, left: padding, right: padding, bottom: padding),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(padding),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
          ),
          child: Center(
            child: Text('Purchase complete',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          )),
    );
  }
}

class ProblemPopup extends StatelessWidget {
  const ProblemPopup({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double padding = 30;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
          padding: EdgeInsets.only(top: padding, left: padding, right: padding, bottom: padding),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(padding),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
          ),
          child: Center(
            child: Text('There was a problem processing this order. Please try again. ',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          )),
    );
  }
}

class ConfirmPurchase extends StatefulWidget {
  final double oldPrice;
  final double newPrice;

  // TODO: implement countdown timer

  ConfirmPurchase({@required this.oldPrice, @required this.newPrice});

  @override
  _ConfirmPurchaseState createState() => _ConfirmPurchaseState();
}

class _ConfirmPurchaseState extends State<ConfirmPurchase> {
  Widget selectedContent;
  int contentId = 0;

  @override
  Widget build(BuildContext context) {
    const double padding = 30;

    if (contentId == 0) {
      selectedContent = Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Text(
            'The price has changed',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Text(
              'Since you last synchronised prices with the server, the payout for this sale has changed from',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(formatCurrency(-widget.oldPrice, 'GBP'), style: TextStyle(fontSize: 18.0)),
              Text('to', style: TextStyle(fontSize: 16.0)),
              Text(formatCurrency(-widget.newPrice, 'GBP'), style: TextStyle(fontSize: 18.0))
            ],
          ),
          SizedBox(height: 20),
          Text(
              'Thats a${widget.oldPrice > widget.newPrice ? "n increase" : " decrease"} of ${formatCurrency((widget.newPrice - widget.oldPrice).abs(), 'GBP')}. Would you still like to proceed with this sale? ',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center),
          SizedBox(height: 24.0),
          TweenAnimationBuilder(
            duration: Duration(seconds: 30),
            tween: Tween<double>(begin: 1, end: 0),
            curve: Curves.linear,
            builder: (BuildContext context, double value, Widget child) {
              return LinearProgressIndicator(
                backgroundColor: Colors.grey,
                value: value,
              );
            },
            onEnd: () async {
              setState(() {
                contentId = 1;
              });
              await Future.delayed(Duration(seconds: 1));
              Navigator.of(context).pop(false);
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                color: Colors.blue[400],
                onPressed: () async {
                  setState(() {
                    contentId = 1;
                  });
                  await Future.delayed(Duration(seconds: 1));
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'No, cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              FlatButton(
                color: Colors.blue[400],
                onPressed: () async {
                  setState(() {
                    contentId = 2;
                  });
                  await Future.delayed(Duration(seconds: 1));
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Yes, proceed',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )
        ],
      );
    } else if (contentId == 1) {
      selectedContent = Center(
        child: Text(
          'Cancelling order',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      );
    } else if (contentId == 2) {
      selectedContent = Center(
        child: Text(
          'Confirming Order',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: AnimatedContainer(
          duration: Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
          height: contentId == 0 ? 377 : 90,
          padding: EdgeInsets.only(top: padding, left: padding, right: padding, bottom: padding),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(padding),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
          ),
          child: selectedContent),
    );
  }
}

class CongratualtionsDialogue extends StatefulWidget {
  @override
  _CongratualtionsDialogueState createState() => _CongratualtionsDialogueState();
}

class _CongratualtionsDialogueState extends State<CongratualtionsDialogue> {
  ConfettiController controllerTopCenter;

  @override
  void initState() {
    super.initState();
    setState(() {
      initController();
    });
  }

  void initController() {
    controllerTopCenter = ConfettiController(duration: const Duration(seconds: 1));
    controllerTopCenter.play();
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 30;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(top: padding, left: padding, right: padding),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(padding),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                maximumSize: Size(20, 20),
                shouldLoop: false,
                confettiController: controllerTopCenter,
                blastDirection: 3.14159 / 2,
                blastDirectionality: BlastDirectionality.directional,
                maxBlastForce: 12, // set a lower max blast force
                minBlastForce: 2, // set a lower min blast force
                emissionFrequency: 1,
                numberOfParticles: 8, // a lot of particles at once
                gravity: 0.05,
              ),
            ),
            Text(
              'Congratulations!!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Text(
                'Congratulations on completing your first purchase! You can now check it out by navigating back to the home screen and tapping on portfolios. ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 24.0),
            Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                color: Colors.blue[400],
                onPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
                child: Text(
                  'OK!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SwipeDownTopBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    Path path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// TODO: add countdown timer
class SecondsLinearProgress extends StatefulWidget {
  final timeout;
  final _total;

  SecondsLinearProgress(this._total, {this.timeout});

  @override
  _SecondsLinearProgressState createState() =>
      _SecondsLinearProgressState(timeout != null ? timeout : _total, _total);
}

class _SecondsLinearProgressState extends State<SecondsLinearProgress> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  int _timeout;
  int _total;

  _SecondsLinearProgressState(this._timeout, this._total);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(seconds: _timeout), vsync: this);
    animation = Tween(begin: _timeout.toDouble() / _total.toDouble(), end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: LinearProgressIndicator(
        value: animation.value,
        backgroundColor: Colors.black26,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
