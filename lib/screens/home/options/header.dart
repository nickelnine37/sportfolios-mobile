import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/numerical/arrays.dart';
import '../../../data/objects/markets.dart';
import '../../../utils/strings/number_format.dart';

import 'buy_contract.dart';

class TeamPageHeader extends StatelessWidget {
  final Array quantity;
  final Market market;
  final Widget infoBox;
  final String contract_type;

  TeamPageHeader(this.quantity, this.market, this.infoBox, this.contract_type);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                Text(
                  formatCurrency(market.currentLMSR!.getValue(quantity), 'GBP'),
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
        Expanded(
          flex: 1,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(Size(100, 35)),
                        overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ))),
                    child: Text('BUY', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        elevation: 100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                        context: context,
                        builder: (context) {
                          return BuyMarket(this.market, this.quantity, contract_type);
                        },
                      );
                    }, // minWidth: MediaQuery.of(context).size.width * 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(     
          flex: 1,
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.info_outline,
                size: 25,
                color: Colors.grey[700],
              ),
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
      ],
    );
  }
}

class PlayerPageHeader extends StatelessWidget {
  final bool long;
  final Market market;
  final Widget infoBox;

  PlayerPageHeader(this.long, this.market, this.infoBox) {}

  @override
  Widget build(BuildContext context) {
    Array unitQuantity = Array.fromList(long ? <double>[10.0, 0.0] : <double>[0.0, 10.0]);

    return Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Expanded(
        flex: 1,
        child: Center(
          child: FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                Text(
                  formatCurrency(market.currentLMSR!.getValue(unitQuantity), 'GBP'),
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
      ),
      Expanded(
        flex: 1, 
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(Size(100, 35)),
                      overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ))),
                  child: Text('BUY', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      elevation: 100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                      context: context,
                      builder: (context) {
                        return BuyMarket(this.market, unitQuantity, long ? 'Long' : 'Short');
                      },
                    );
                  }, // minWidth: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Center(
          child: IconButton(
            icon: Icon(
              Icons.info_outline,
              size: 25,
              color: Colors.grey[700],
            ),
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
