import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart' as intl;

import '../../../data/api/requests.dart';
import '../../../data/firebase/portfolios.dart';
import '../../../data/objects/markets.dart';
import '../../../utils/authentication/authenication_provider.dart';
import '../../../utils/strings/number_format.dart';
import '../../../utils/numerical/numbers.dart';
import '../../../data/objects/portfolios.dart';
import '../../../plots/payout_graph.dart';
import '../../../utils/numerical/arrays.dart';

/// this can be used to notify other widgets that a purchase has been made
final purchaseCompleteProvider = ChangeNotifierProvider<PurchaseCompleteChangeNotifier>((ref) {
  return PurchaseCompleteChangeNotifier();
});

class PurchaseCompleteChangeNotifier with ChangeNotifier {
  int? _transactionId;
  Transaction? _transaction;
  String? _portfolioId;

  String? get portfolio => _portfolioId;
  Transaction? get transaction => _transaction;
  int? get transactionId => _transactionId;

  void registrNewTransaction(String portfolioId, Transaction transaction) {
    if (_transactionId == null) {
      _transactionId = 0;
    } else {
      _transactionId = _transactionId! + 1;
    }

    _transaction = transaction;
    _portfolioId = portfolioId;

    notifyListeners();
  }
}

class BuyMarket extends StatefulWidget {
  final Market market;
  final Array unitQuantity;
  final String contract_type;

  BuyMarket(this.market, this.unitQuantity, this.contract_type);

  @override
  _BuyMarketState createState() => _BuyMarketState();
}

class _BuyMarketState extends State<BuyMarket> {
  Future? _portfoliosFuture;

  @override
  void initState() {
    super.initState();
    _portfoliosFuture = Future.wait(<Future>[_getPortfolios(), widget.market.getCurrentHoldings()]);
  }

  Future<List<Portfolio>> _getPortfolios() async {
    AuthService _authService = AuthService();
    List<Portfolio> out = [];
    fire.DocumentSnapshot userSnapshot = await fire.FirebaseFirestore.instance.collection('users').doc(_authService.currentUid).get();
    List<String> portfolioIds = List<String>.from(userSnapshot['portfolios']);
    for (String portfolioId in portfolioIds) {
      out.add((await getPortfolioById(portfolioId))!);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: widget.market.id.contains('T') ? 610 : 450,
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
                    height: 20, width: MediaQuery.of(context).size.width * 0.35, child: CustomPaint(painter: SwipeDownTopBarPainter())),
                SizedBox(height: 5),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          '${widget.market.name}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 3),
                        Text('Contract type: ${widget.contract_type}'),
                        SizedBox(height: 5),
                        Divider(thickness: 2, height: 25),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                          CachedNetworkImage(
                            imageUrl: widget.market.imageURL!,
                            height: 50,
                          ),
                          Column(
                            children: [
                              Text('Per contract'),
                              SizedBox(height: 3),
                              Text(
                                formatCurrency(widget.market.currentLMSR!.getValue(widget.unitQuantity), 'GBP'),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Payout date'),
                              SizedBox(height: 3),
                              Text(
                                intl.DateFormat.yMMMd().format(widget.market.endDate!),
                                // TODO: add market expirey date
                                // DateFormat('d MMM yy').format(widget.league.endDate),
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ]),
                        Divider(thickness: 2, height: 25),
                        widget.market.id.contains('T') ? PayoutGraph(q: widget.unitQuantity, tappable: true) : Container(),
                        SizedBox(height: 0),
                        FutureBuilder(
                            future: _portfoliosFuture,
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return BuyForm(snapshot.data[0], widget.market, widget.unitQuantity);
                              } else if (snapshot.hasError) {
                                print(snapshot.error);
                                return Center(child: Text('Error'));
                              } else {
                                return CircularProgressIndicator();
                              }
                            }),
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

class BuyForm extends StatefulWidget {
  final List<Portfolio>? portfolios;
  final Market market;
  final Array unitQuantity;

  BuyForm(this.portfolios, this.market, this.unitQuantity);

  @override
  _BuyFormState createState() => _BuyFormState();
}

class _BuyFormState extends State<BuyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _unitController = TextEditingController();
  double units = 0;
  double price = 0;
  bool loading = false;
  bool complete = false;
  bool team = false;

  String? _selectedPortfolioId;

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.portfolios!.length == 0) {
      _selectedPortfolioId = 'new';
    } else {
      _selectedPortfolioId = widget.portfolios![0].id;
    }
    team = widget.market.id.contains('T');

    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Portfolio', style: TextStyle(fontSize: 17, color: Colors.grey[850])),
                    IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () {
                          print('Portfolio Info ');
                        },
                        iconSize: 20)
                  ],
                ),
                Container(
                  width: 150,
                  height: 100,
                  child: Center(
                    child: DropdownButtonFormField(
                      itemHeight: 100,
                      value: _selectedPortfolioId,
                      items: List<DropdownMenuItem<String>>.from(widget.portfolios!.map((portfolio) => DropdownMenuItem(
                              onTap: () {},
                              value: portfolio.id,
                              child: Text(
                                portfolio.name,
                                style: TextStyle(color: Colors.grey[850]),
                              )))) +
                          <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: 'new',
                              child: Row(
                                children: [
                                  Text('New', style: TextStyle(color: Colors.grey[850])),
                                  Icon(
                                    Icons.add,
                                    size: 20,
                                  )
                                ],
                              ),
                              onTap: () {
                                print('Create new portfolo dialogue');
                              },
                            ),
                          ],
                      onChanged: (String? id) {
                        // _selectedPortfolio = widget.portfolios.firstWhere((Portfolio p) => p.id == id);

                        setState(() {
                          _selectedPortfolioId = id;
                        });
                      },
                      onSaved: (String? id) {
                        // _selectedPortfolio = widget.portfolios.firstWhere((Portfolio p) => p.id == id);
                        _selectedPortfolioId = id;
                      },
                      validator: (String? value) {
                        if (widget.portfolios!.map((portfolio) => portfolio.id).contains(value) || value == 'new') {
                          // TODO: check whether portfolio has sufficient cash
                          return null;
                        } else {
                          return 'Please select a valid portfolio';
                        }
                      },
                      isExpanded: true,
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Units', style: TextStyle(fontSize: 17, color: Colors.grey[850])),
                    IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () {
                          print('Show units info dialogue');
                        },
                        iconSize: 20)
                  ],
                ),
                Container(
                  width: 150,
                  height: 50,
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
                    // maxLength: 5,
                    controller: _unitController,
                    decoration: InputDecoration(hintText: '0.00'),
                    onChanged: (String value) {
                      if (value == '') {
                      } else {
                        try {
                          units = double.parse(value);
                          Array qPurchase = widget.unitQuantity.scale(units);
                          price = validatePrice(widget.market.currentLMSR!.priceTrade(qPurchase));
                          setState(() {});
                        } catch (error) {
                          print(error.toString());
                        }
                      }
                    },
                    validator: (String? value) {
                      try {
                        double.parse(value!);
                        if (price >= widget.portfolios!.firstWhere((portfolio) => portfolio.id == _selectedPortfolioId).cash) {
                          return 'Insufficient funds';
                        }
                        return null;
                      } catch (error) {
                        return 'Please input valid units';
                      }
                    },
                    onSaved: (String? value) {
                      units = double.parse(value!);
                    },
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price:',
                  style: TextStyle(fontSize: 17, color: Colors.grey[850]),
                ),
                Text(
                  formatCurrency(price, 'GBP'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                TextButton(
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
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(Colors.blue),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () async {
                    if (!complete) {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      } else {
                        return;
                      }

                      if (!FocusScope.of(context).hasPrimaryFocus) {
                        FocusManager.instance.primaryFocus!.unfocus();
                      }

                      // off we go...
                      setState(() {
                        loading = true;
                      });

                      // set the quantity being purchased
                      Array qPurchase = widget.unitQuantity.scale(units);

                      // make a new purchase request
                      Map<String, dynamic>? purchaseRequestResult =
                          await makePurchaseRequest(widget.market.id, _selectedPortfolioId!, qPurchase, price);

                      // something fucked up happened ...
                      if (purchaseRequestResult == null) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ProblemPopup();
                            });
                        await Future.delayed(Duration(milliseconds: 600));
                        Navigator.of(context).pop();
                        return;
                      }

                      // we need this to congratulate etc
                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      await Future.delayed(Duration(seconds: 1));

                      // everything went according to plan
                      if (purchaseRequestResult['success']) {
                        setState(() {
                          loading = false;
                          complete = true;
                        });

                        // Notify portfolios that a new transaction has been made
                        print('Notifying!!');

                        Transaction transaction = Transaction(
                          widget.market,
                          DateTime.now().millisecondsSinceEpoch / 1000,
                          price,
                          qPurchase,
                        );

                        context.read(purchaseCompleteProvider).registrNewTransaction(_selectedPortfolioId!, transaction);

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return PurchaseCompletePopup();
                            });

                        await Future.delayed(Duration(milliseconds: 800));
                        Navigator.of(context).pop();

                        // if this is null, lets congratulate
                        bool? done = prefs.getBool('firstPurchaseComplete');

                        if (done == null) {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CongratualtionsDialogue();
                              });
                          prefs.setBool('firstPurchaseComplete', true);
                        }

                        await Future.delayed(Duration(milliseconds: 500));

                        Navigator.pop(context);
                      }

                      // the price was not as expected
                      else {
                        setState(() {
                          loading = false;
                          complete = false;
                        });

                        bool confirm = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ConfirmPurchase(oldPrice: price, newPrice: purchaseRequestResult['price']);
                                }) ??
                            false;

                        bool ok = await respondToNewPrice(confirm, purchaseRequestResult['cancelId']);

                        // they want to confirm, but there is a problem
                        if (confirm && !ok) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ProblemPopup();
                              });
                          await Future.delayed(Duration(seconds: 1));
                          Navigator.of(context).pop();
                        }

                        // they want to confirm and there's no problem
                        else if (confirm && ok) {
                          setState(() {
                            price = purchaseRequestResult['price'];
                            loading = false;
                            complete = true;
                          });

                          Transaction transaction = Transaction(
                            widget.market,
                            DateTime.now().millisecondsSinceEpoch / 1000,
                             purchaseRequestResult['price'],
                            qPurchase,
                          );

                          context.read(purchaseCompleteProvider).registrNewTransaction(_selectedPortfolioId!, transaction);

                          // check for congrats
                          bool? done = prefs.getBool('firstPurchaseComplete');

                          if (done == null) {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CongratualtionsDialogue();
                                });
                            prefs.setBool('firstPurchaseComplete', true);
                          }
                          await Future.delayed(Duration(milliseconds: 600));
                          Navigator.of(context).pop();
                        } 
                        
                        // they rejected the new price
                        else if (!confirm) {
                          await Future.delayed(Duration(milliseconds: 600));
                          Navigator.of(context).pop();
                        }
                      }
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PurchaseCompletePopup extends StatelessWidget {
  const PurchaseCompletePopup({Key? key}) : super(key: key);

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
            child: Text('Purchase complete', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          )),
    );
  }
}

class ProblemPopup extends StatelessWidget {
  const ProblemPopup({Key? key}) : super(key: key);

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
  final double? oldPrice;
  final double? newPrice;

  // TODO: implement countdown timer

  ConfirmPurchase({required this.oldPrice, required this.newPrice});

  @override
  _ConfirmPurchaseState createState() => _ConfirmPurchaseState();
}

class _ConfirmPurchaseState extends State<ConfirmPurchase> {
  Widget? selectedContent;
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
          Text('Since you last synchronised prices with the server, the cost of this order has changed from',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(formatCurrency(widget.oldPrice, 'GBP'), style: TextStyle(fontSize: 18.0)),
              Text('to', style: TextStyle(fontSize: 16.0)),
              Text(formatCurrency(widget.newPrice, 'GBP'), style: TextStyle(fontSize: 18.0))
            ],
          ),
          SizedBox(height: 20),
          Text(
              'Thats a${widget.newPrice! > widget.oldPrice! ? "n increase" : " decrease"} of ${formatCurrency((widget.newPrice! - widget.oldPrice!).abs(), 'GBP')}. Would you still like to proceed with this purchase? ',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center),
          SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
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
              TextButton(
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!)),
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
          'Order Cancelled',
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
          height: contentId == 0 ? 360 : 90,
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
  late ConfettiController controllerTopCenter;

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
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                ),
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
  _SecondsLinearProgressState createState() => _SecondsLinearProgressState(timeout != null ? timeout : _total, _total);
}

class _SecondsLinearProgressState extends State<SecondsLinearProgress> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  int? _timeout;
  int _total;

  _SecondsLinearProgressState(this._timeout, this._total);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(seconds: _timeout!), vsync: this);
    animation = Tween(begin: _timeout!.toDouble() / _total.toDouble(), end: 0.0).animate(controller)
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
