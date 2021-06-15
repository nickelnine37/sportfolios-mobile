import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/screens/home/app_bar.dart';
import 'package:sportfolios_alpha/screens/home/footers/stats.dart';
import 'package:sportfolios_alpha/screens/home/market_tile.dart';
import 'package:sportfolios_alpha/screens/home/options/team_players.dart';
import 'package:sportfolios_alpha/utils/design/colors.dart';
import 'package:sportfolios_alpha/utils/strings/number_format.dart';

import 'binary.dart';
import 'custom.dart';
import 'long_short.dart';

class MarketDetails extends StatefulWidget {
  final Market market;

  MarketDetails(this.market);

  @override
  _MarketDetailsState createState() => _MarketDetailsState();
}

class _MarketDetailsState extends State<MarketDetails> {
  Future updateState;

  @override
  void initState() {
    updateState = Future.wait([
          widget.market.lmsr.updateCurrentX(),
          widget.market.lmsr.updateHistoricalX(),
          Future.delayed(Duration(seconds: 3)),
        ] +
        (widget.market.type == 'player' ? [widget.market.getTeamSnapshot()] : []));
    super.initState();
  }

  // Future awaitCurrentX() async {
  //   return await getcurrentX(widget.market.id);
  // }

  // Future awaitHistoricalX() async {
  //   return await getHistoricalX(widget.market.id);
  // }

  @override
  Widget build(BuildContext context) {
    Color background = fromHex(widget.market.colours[0]);
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
                Icon(Icons.bar_chart, size: 20, color: Colors.blue[800])
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
                Container(child: CachedNetworkImage(imageUrl: widget.market.imageURL, height: 50)),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.market.name, style: TextStyle(fontSize: 23.0, color: textColor)),
                    SizedBox(height: 2),
                    Text(
                      '${widget.market.info1} • ${widget.market.info2} • ${widget.market.info3}',
                      style: TextStyle(fontSize: 13.0, color: textColor, fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: LeagueProgressBar(
                leagueOrMarket: widget.market,
                textColor: textColor,
              ),
            ),
          ]),
        ),
        body: FutureBuilder(
          future: updateState,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  LongShortDetails(widget.market, 'Long'),
                  LongShortDetails(widget.market, 'Short'),
                  BinaryDetails(widget.market),
                  CustomDetails(widget.market),
                ],
              );
            } else if (snapshot.hasError) {
              return Container(child: Center(child: Text(snapshot.error.toString())));
            } else {
              return Container(child: Center(child: CircularProgressIndicator()));
            }
          },
        ),
      ),
    );
  }
}

// class MarketPageHeader extends ConsumerWidget {
//   final Market market;
//   const MarketPageHeader(this.market);

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     String currency = watch(settingsProvider).currency;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//       child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             CachedNetworkImage(
//               imageUrl: market.imageURL,
//               height: 65,
//             ),
//             SizedBox(height: 3),
//             Text(
//               formatCurrency(market.currentBackValue, currency),
//               style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
//             ),
//             Column(
//               children: [
//                 Text('Expirey date'),
//                 SizedBox(height: 3),
//                 Text(
//                   DateFormat('d MMM yy').format(market.startDate),
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
//                 ),
//               ],
//             ),
//           ]),
//     );
//   }
// }

class PageFooter extends StatelessWidget {
  final Market market;

  PageFooter(this.market);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Container(
                height: 60,
                child: Center(
                  child: ListTile(
                    onTap: () {},
                    leading: SizedBox(
                      height: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.donut_large,
                            size: 28,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Portfolios',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(Icons.arrow_right, size: 28),
                  ),
                ),
              ),
              Divider(thickness: 2),
              Container(
                height: 60,
                child: Center(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
                        return StatsShow(market, '2020/2021');
                      }));
                    },
                    leading: SizedBox(
                      height: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insights,
                            size: 28,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Statistics',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(Icons.arrow_right, size: 28),
                  ),
                ),
              ),
              Divider(thickness: 2),
            ] +
            (market.type == 'team'
                ? [
                    Container(
                      height: 60,
                      child: Center(
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
                              return TeamPlayers(market);
                            }));
                          },
                          leading: SizedBox(
                            height: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.group,
                                  size: 28,
                                ),
                                SizedBox(width: 15),
                                Text(
                                  'Players',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(Icons.arrow_right, size: 28),
                        ),
                      ),
                    ),
                    Divider(thickness: 2)
                  ]
                : [
                    Container(
                      height: 60,
                      child: Center(
                        child: ListTile(
                          // onTap: () {},
                          leading: SizedBox(
                            height: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.group,
                                  size: 28,
                                ),
                                SizedBox(width: 15),
                                Text(
                                  'Team',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    MarketTile(market: market.team),
                    Divider(thickness: 2)
                  ]));
  }
}
