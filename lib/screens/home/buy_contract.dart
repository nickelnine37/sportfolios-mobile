import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/data_models/leagues.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/dialogues.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';
import 'package:intl/intl.dart';

class BuyContract extends StatefulWidget {
  final Contract contract;
  final League league;

  BuyContract(this.contract, this.league);

  @override
  _BuyContractState createState() => _BuyContractState();
}

class _BuyContractState extends State<BuyContract> {
  final TextEditingController _unitController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

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
                            '${widget.contract.contractType.contains('long') ? ', long' : ', short'}',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text('Portfolio', style: TextStyle(fontSize: 17)),
                            IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return BasicDialog(
                                          title: 'Portfolio: information',
                                          description:
                                              "Select a portfolio to add your purchase to, or create a new one. ",
                                          buttonText: 'OK',
                                          action: () {},
                                        );
                                      });
                                },
                                iconSize: 20)
                          ],
                        ),
                        Container(
                          width: 120,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: DropdownButton(
                            isExpanded: true,
                            value: 1,
                            items: range(3)
                                .map((i) => DropdownMenuItem(child: Text('Portfolio${i + 1}'), value: i + 1))
                                .toList(),
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text('Units', style: TextStyle(fontSize: 17)),
                            IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return BasicDialog(
                                          title: 'Units: information',
                                          description:
                                              "'Units' refers to the amount of a contract you want to buy. The price of your purchase will be the number of units multiplied by the individual contract price, and the payout will be the number of units multiplied by the contract payout. You don't have to buy a whole number of units - any number up to two decimal places is fine. ",
                                          buttonText: 'OK',
                                          action: () {},
                                        );
                                      });
                                },
                                iconSize: 20)
                          ],
                        ),
                        Container(
                          width: 120,
                          padding: EdgeInsets.all(10.0),
                          child: TextFormField(
                            controller: _unitController,
                            autocorrect: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: formatDecimal(0, currency)),
                            onChanged: (String value) {
                              if (value != '' && value != null) {
                                _priceController.text =
                                    formatCurrency(double.parse(value) * widget.contract.value, currency);
                              } else {
                                _priceController.text = formatCurrency(0, currency);
                              }
                            },
                            onFieldSubmitted: (String value) {
                              _unitController.text = formatDecimal(double.parse(value), currency);
                            },
                            // onSaved: ,
                          ),
                          //
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Price', style: TextStyle(fontSize: 17)),
                        Container(
                          width: 120,
                          padding: EdgeInsets.all(10.0),
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: formatCurrency(0, currency)),
                            onChanged: (String value) {
                              if (value != '' && value != null) {
                                _unitController.text =
                                    formatDecimal(double.parse(value) / widget.contract.value, currency);
                              } else {
                                _unitController.text = formatCurrency(0, currency);
                              }
                            },
                            onEditingComplete: null,
                            onSubmitted: (String value) {
                              _unitController.text = formatDecimal(double.parse(value), currency);
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FlatButton(
                          color: Colors.blue,
                          child: Text('OK', style: TextStyle(color: Colors.white)),
                          onPressed: () {},
                        )
                      ],
                    )
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
