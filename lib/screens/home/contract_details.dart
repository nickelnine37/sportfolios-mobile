import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/data/models/leagues.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/screens/home/app_bar.dart';
import 'package:sportfolios_alpha/utils/colors.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

import 'options/binary.dart';
import 'options/custom.dart';
import 'options/long_short.dart';

class ContractDetails extends StatefulWidget {
  final Contract contract;
  final League league;

  ContractDetails(this.contract, this.league);

  @override
  _ContractDetailsState createState() => _ContractDetailsState();
}

class _ContractDetailsState extends State<ContractDetails> {
  Future holdings;

  @override
  void initState() {
    holdings = Future.wait(
        [awaitCurrentHoldings(), awaitHistoricalHoldings(), Future.delayed(Duration(seconds: 3))]);
    super.initState();
  }

  Future awaitCurrentHoldings() async {
    return await getcurrentHoldings(widget.contract.id);
  }

  Future awaitHistoricalHoldings() async {
    return await getHistoricalHoldings(widget.contract.id);
  }

  @override
  Widget build(BuildContext context) {
    Color background = fromHex(widget.contract.colours[0]);
    Color textColor = background.computeLuminance() > 0.5 ? Colors.grey[700] : Colors.white;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
              decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [background, Colors.white],
                begin: const FractionalOffset(0.4, 0.5),
                end: const FractionalOffset(1, 0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          )),
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          toolbarHeight: 145,
          bottom: TabBar(
            labelPadding: EdgeInsets.all(5),
            tabs: <Row>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text('Long', style: TextStyle(fontSize: 14.0, color: textColor)),
                Icon(Icons.trending_up, size: 20, color: Colors.green[600])
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text('Short', style: TextStyle(fontSize: 14.0, color: textColor)),
                Icon(Icons.trending_down, size: 20, color: Colors.red[600])
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text('Binary', style: TextStyle(fontSize: 14.0, color: textColor)),
                Transform.rotate(
                    angle: 3.14159 / 2,
                    child: Icon(Icons.vertical_align_center, size: 20, color: Colors.blue[800])),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text('Custom', style: TextStyle(fontSize: 14.0, color: textColor)),
                Icon(Icons.signal_cellular_alt, size: 20, color: Colors.blue[800])
              ]),
            ],
          ),
          title: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  color: textColor,
                  icon: Icon(
                    Icons.arrow_back,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Container(child: CachedNetworkImage(imageUrl: widget.contract.imageURL, height: 50)),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.contract.name, style: TextStyle(fontSize: 23.0, color: textColor)),
                    SizedBox(height: 2),
                    Text(
                      '${widget.contract.info1} • ${widget.contract.info2} • ${widget.contract.info3}',
                      style: TextStyle(fontSize: 13.0, color: textColor, fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ],
            ),
            LeagueProgressBar(
              league: widget.league,
              textColor: textColor,
            ),
          ]),
        ),
        body: FutureBuilder(
          future: holdings,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              widget.contract.setCurrentHolding(List<double>.from(snapshot.data[0]['x']), snapshot.data[0]['b']);
              widget.contract.setHistoricalHoldings(snapshot.data[1]['xhist'], snapshot.data[1]['bhist']);

              return TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  LongShortDetails(widget.contract, 'Long'),
                  LongShortDetails(widget.contract, 'Short'),
                  BinaryDetails(widget.contract),
                  CustomDetails(widget.contract),
                ],
              );
            } else {
              return Container(child: Center(child: CircularProgressIndicator()));
            }
          },
        ),
      ),
    );
  }
}

class ContractPageHeader extends ConsumerWidget {
  final Contract contract;
  final League league;
  const ContractPageHeader(this.contract, this.league);

  Widget _valueChangeText(String currency, double valueChange, double percentChange) {
    String sign = valueChange > 0 ? '+' : '-';
    return Text(
      '$sign${formatPercentage(percentChange.abs(), currency)}  ($sign${formatCurrency(valueChange.abs(), currency)})',
      style: TextStyle(
        fontSize: 12,
        color: valueChange > 0 ? Colors.green[300] : Colors.red[300],
      ),
    );
  }

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
              formatCurrency(contract.currentBackValue, currency),
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
  }
}
