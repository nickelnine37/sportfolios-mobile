import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/data/models/leagues.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';
import 'package:intl/intl.dart';

class PortfolioWireframe {
  final String name;
  final String id;

  PortfolioWireframe(this.name, this.id);
}

class BuyContract extends StatefulWidget {
  final Contract contract;
  final League league;

  BuyContract(this.contract, this.league);

  @override
  _BuyContractState createState() => _BuyContractState();
}

class _BuyContractState extends State<BuyContract> {
  Future<List<PortfolioWireframe>> _portfoliosFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _portfoliosFuture = _getPortfolios();
  }

  Future<List<PortfolioWireframe>> _getPortfolios() async {
    AuthService _authService = AuthService();
    List<PortfolioWireframe> out = [];
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(_authService.currentUid).get();
    List<String> portfolioIds = List<String>.from(userSnapshot.data()['portfolios']);
    print(portfolioIds);
    for (String portfolioId in portfolioIds) {
      DocumentSnapshot portfolioSnapshot =
          await FirebaseFirestore.instance.collection('portfolios').doc(portfolioId).get();
      out.add(PortfolioWireframe(portfolioSnapshot.data()['name'], portfolioSnapshot.id));
    }
    return out;
  }

  double contractPrice = 15.05;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
            ),
          ),
          child: Consumer(builder: (context, watch, child) {
            String currency = watch(settingsProvider).currency;

            return Container(
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
                    Text(
                        'Buy ' +
                            widget.contract.name +
                            ', ${widget.contract.longOrShort}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                    SizedBox(height: 5),
                    Divider(thickness: 2, height: 25),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.contract.imageURL,
                            height: 50,
                          ),
                          Column(
                            children: [
                              Text('Unit price'),
                              SizedBox(height: 3),
                              Text(
                                formatCurrency(widget.contract.value, currency),
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Expirey date'),
                              SizedBox(height: 3),
                              Text(
                                DateFormat('d MMM yy').format(widget.league.startDate),
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ]),
                    Divider(thickness: 2, height: 25),
                    FutureBuilder(
                        future: _portfoliosFuture,
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return BuyForm(snapshot.data, widget.contract, currency);
                          } else if (snapshot.hasError) {
                            print(snapshot.error);
                            return Center(child: Text('Error'));
                          } else {
                            return CircularProgressIndicator();
                          }
                        })
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class BuyForm extends StatefulWidget {
  final List<PortfolioWireframe> portfolios;
  final Contract contract;
  final String currency;

  BuyForm(this.portfolios, this.contract, this.currency);

  @override
  _BuyFormState createState() => _BuyFormState();
}

class _BuyFormState extends State<BuyForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedPortfolioId;
  Map<String, dynamic> _finalFormFields = {'portfolioId': null, 'units': null, 'price': null};

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.portfolios.length == 0) {
      _selectedPortfolioId = 'new';
    } else {
      _selectedPortfolioId = widget.portfolios[0].id;
    }
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
                    Text('Portfolio', style: TextStyle(fontSize: 17)),
                    IconButton(icon: Icon(Icons.info_outline), onPressed: () {}, iconSize: 20)
                  ],
                ),
                Container(
                  width: 100,
                  height: 50,
                  child: Center(
                    child: DropdownButtonFormField(
                      value: _selectedPortfolioId,
                      items: List<DropdownMenuItem<String>>.from(widget.portfolios.map((portfolio) =>
                              DropdownMenuItem(
                                  onTap: () {}, value: portfolio.id, child: Text(portfolio.name)))) +
                          <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: 'new',
                              child: Row(
                                children: [
                                  Text('New'),
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
                      onChanged: (String id) {
                        print(id);
                        setState(() {
                          _selectedPortfolioId = id;
                        });
                      },
                      validator: (String value) {
                        if (widget.portfolios.map((portfolio) => portfolio.id).contains(value) ||
                            value == 'new') return null;
                        return 'Please select a valid portfolio';
                      },
                      onSaved: (String value) {
                        _finalFormFields['portfolioId'] = value;
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
                    Text('Units', style: TextStyle(fontSize: 17)),
                    IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () {
                          print('Show units info dialogue');
                        },
                        iconSize: 20)
                  ],
                ),
                Container(
                  width: 100,
                  height: 50,
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                    ],
                    // maxLength: 5,
                    controller: _unitController,
                    decoration: InputDecoration(hintText: '0.00'),
                    onChanged: (String value) {
                      if (value == null || value == '') {
                        // _priceController.text = null;
                        _priceController.text = '';
                      } else {
                        try {
                          // _unitController.text = value;
                          _priceController.text =
                              formatDecimal(double.parse(value) * widget.contract.value, widget.currency);
                        } catch (error) {
                          print(error.toString());
                        }
                      }
                    },
                    validator: (String value) {
                      try {
                        double.parse(value);
                        return null;
                      } catch (error) {
                        return 'Please input valid units';
                      }
                    },
                    onSaved: (String value) {
                      _finalFormFields['units'] = double.parse(value);
                    },
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Price', style: TextStyle(fontSize: 17)),
                    IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () {
                          print('Show price info dialogue');
                        },
                        iconSize: 20)
                  ],
                ),
                Container(
                  width: 113,
                  height: 48,
                  child: Row(
                    children: [
                      Text(getCurrencySymbol(widget.currency)),
                      SizedBox(width: 5),
                      Container(
                        width: 100,
                        height: 48,
                        child: TextFormField(
                          keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                          controller: _priceController,
                          decoration: InputDecoration(hintText: '0.00'),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                          ],
                          onChanged: (String value) {
                            if (value == null || value == '') {
                              _unitController.text = '';
                            } else {
                              try {
                                // _priceController.text = value;
                                _unitController.text = formatDecimal(
                                    double.parse(value) / widget.contract.value, widget.currency);
                              } catch (error) {
                                print(error.toString());
                              }
                            }
                          },
                          validator: (String value) {
                            try {
                              double val = double.parse(value);
                              if (val < 0.5) {
                                return 'Vlaue must be more than ${formatCurrency(0.5, widget.currency)}';
                              }
                              return null;
                            } catch (error) {
                              return 'Please input valid price';
                            }
                          },
                          onSaved: (String value) {
                            _finalFormFields['price'] = double.parse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: FlatButton(
                child: Text('OK', style: TextStyle(color: Colors.white)),
                color: Colors.blue,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                  }
                  if (!FocusScope.of(context).hasPrimaryFocus) {
                    FocusManager.instance.primaryFocus.unfocus();
                  }
                  print(_finalFormFields);
                },
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
