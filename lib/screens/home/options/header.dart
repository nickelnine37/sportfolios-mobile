import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

import 'info_box.dart';

class PageHeader extends StatelessWidget {
  final List<double> quantity;
  final Contract contract;
  final InfoBox infoBox;

  PageHeader(this.quantity, this.contract, this.infoBox);

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 80,
            child: Center(
              child: Column(
                children: [
                  Text(
                    formatCurrency(contract.getCurrentValue(quantity), 'GBP'),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                  ),
                  Text(
                    'per contract',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('BUY', style: TextStyle(color: Colors.white)),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  elevation: 100,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                  context: context,
                  builder: (context) {
                    return Container(
                      child: Text('Hey'),
                    );
                  },
                );
              },
              color: Colors.green[400],
              minWidth: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
          Container(
            width: 80,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.info_outline, size: 23),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return infoBox;
                      });
                },
              ),
            ),
          ),
        ]);
  }
}
