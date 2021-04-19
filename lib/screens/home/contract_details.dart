import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/data/models/leagues.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';
import 'package:sportfolios_alpha/screens/home/buy_contract.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

class ContractDetails extends StatefulWidget {
  final Contract contract;
  final League league;

  const ContractDetails(this.contract, this.league);

  @override
  _ContractDetailsState createState() => _ContractDetailsState();
}

class _ContractDetailsState extends State<ContractDetails> {
  Future<PaletteGenerator> paletteFuture;
  PaletteGenerator palette;

  @override
  void initState() {
    super.initState();
    paletteFuture = _getPalette();
  }

  Future<PaletteGenerator> _getPalette() async {
    return await PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(widget.contract.imageURL));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: paletteFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            palette = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[palette.paletteColors[0].color, palette.paletteColors[1].color])),
                ),
                // backgroundColor: palette.paletteColors[0].color,
                title: Text(
                  widget.contract.name +
                      ' (${widget.contract.longOrShort})',
                  style: TextStyle(color: Colors.white),
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              body: SingleChildScrollView(
                child: Column(children: [
                  ContractPageHeader(widget.contract, widget.league),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        child: Text('BUY', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            elevation: 100,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                            context: context,
                            builder: (context) {
                              return BuyContract(widget.contract, widget.league);
                            },
                          );
                        },
                        color: Colors.green[400],
                        minWidth: MediaQuery.of(context).size.width * 0.4,
                      ),
                      SizedBox(width: 10),
                      FlatButton(
                        child: Text('SELL', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              elevation: 100,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                              context: context,
                              builder: (context) {
                                return BuyContract(widget.contract, widget.league);
                              });
                        },
                        color: Colors.red[400],
                        minWidth: MediaQuery.of(context).size.width * 0.4,
                      ),
                    ],
                  ),
                  SizedBox(height: 35),
                  PayoutGraph(range(20).map((i) => exp(i / 5)).toList(), palette.paletteColors[3].color),
                  SizedBox(height: 35),
                  TabbedPriceGraph(
                      instrument: widget.contract,
                      color1: palette.paletteColors[0].color,
                      color2: palette.paletteColors[1].color),
                  SizedBox(height: 35),
                ]),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(appBar: AppBar(title: Text('Error')), body: Center(child: Text('Error')));
          } else {
            return Scaffold(appBar: AppBar(), body: Center(child: CircularProgressIndicator()));
          }
        });
  }
}

class ContractPageHeader extends ConsumerWidget {
  final Contract contract;
  final League league;
  const ContractPageHeader(this.contract, this.league);

  // Widget _valueChangeText(String currency, double valueChange, double percentChange) {
  //   String sign = valueChange > 0 ? '+' : '-';
  //   return Text(
  //     '$sign${formatPercentage(percentChange.abs(), currency)}  ($sign${formatCurrency(valueChange.abs(), currency)})',
  //     style: TextStyle(
  //       fontSize: 12,
  //       color: valueChange > 0 ? Colors.green[300] : Colors.red[300],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    String currency = watch(settingsProvider).currency;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: contract.imageURL,
              height: 65,
            ),
            SizedBox(height: 3),
            Text(
              formatCurrency(contract.value, currency),
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
            ),
            Column(
              children: [
                Text('Expirey date'),
                SizedBox(height: 3),
                Text(
                  DateFormat('d MMM yy').format(league.startDate),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ]),
    );

//     return Container(
//       padding: EdgeInsets.only(left: 15, right: 25, bottom: 15, top: 25),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(children: [
//             contract.imageURL != null
//                 ? Container(height: 65, width: 65, child: CachedNetworkImage(imageUrl: contract.imageURL))
//                 : Container(height: 65, width: 65),
//             SizedBox(width: 15),
//             Container(
//               height: 65,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Last 24h: ', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                       Text('Since start: ', style: TextStyle(color: Colors.grey[600], fontSize: 12))
//                     ],
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _valueChangeText(currency, contract.dayValueChange, contract.dayReturn),
//                       _valueChangeText(currency, contract.totalValueChange, contract.totalReturn)
//                     ],
//                   ),
//                 ],
//               ),
//             )
//           ]),
//           Text(
//             formatCurrency(contract.value, currency),
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
//           )
//         ],
//       ),
//     );
  }
}
