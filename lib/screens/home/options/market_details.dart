import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/plots/payout_graph.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';
import 'package:sportfolios_alpha/screens/home/market_tile.dart';
import 'package:sportfolios_alpha/screens/home/options/header.dart';
import 'package:sportfolios_alpha/screens/home/options/info_box.dart';
import 'package:sportfolios_alpha/utils/numerical/arrays.dart';

import '../../../data/objects/markets.dart';
import '../app_bar.dart';
import '../footers/stats.dart';
import 'team_players.dart';
import '../../../utils/design/colors.dart';
import 'dart:math' as math;
import '../../../utils/numerical/array_operations.dart';

class TeamDetails extends StatefulWidget {
  final Market market;
  TeamDetails(this.market);

  @override
  _TeamDetailsState createState() => _TeamDetailsState();
}

class _TeamDetailsState extends State<TeamDetails> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Future<void>? updateState;

  List<Array>? qs;

  bool reversed = false;
  int? n;
  int selected = 0;
  double graphPadding = 35;
  double graphHeight = 150.0;
  double? graphWidth;
  bool locked = true;

  InfoBox longInfo = InfoBox(title: 'Long contract', pages: [
    MiniInfoPage(
        'A long contract pays out more and more the higher a team places in the league, up to a maxmimum payout of £10 for 1st place.',
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.signal_cellular_alt, size: 80),
            Text(
              ' 3    2    1',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
        Colors.blue[600]),
    MiniInfoPage(
        'This makes it a great buy if you believe a team\'s potential is underestimated. The more the team outperforms relative to expectations, the more your asset will climb in value.',
        Icon(Icons.trending_up, size: 80),
        Colors.green[600]),
  ]);

  InfoBox shortInfo = InfoBox(title: 'Short contract', pages: [
    MiniInfoPage(
        'A short contract pays out more and more the lower a team places in the league, up to a maxmimum payout of £10 for last place.',
        Column(
          children: [
            Transform(alignment: Alignment.center, transform: Matrix4.rotationY(math.pi), child: Icon(Icons.signal_cellular_alt, size: 80)),
            Text(
              '20   19   18',
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
        Colors.blue[600]),
    MiniInfoPage(
        'This makes the short a great buy if you believe a team\'s potential is overestimated. The more the team underperforms relative to expectations, the more your asset will climb in value.',
        Icon(Icons.trending_down, size: 80),
        Colors.red[600])
  ]);

  InfoBox binaryInfo = InfoBox(title: 'Binary contract', pages: [
    MiniInfoPage(
        'A binary contract has a payout of either £10 or £0, depending on whether a team finishes higher or lower than a given league position.',
        Transform.rotate(angle: 3.14159 / 2, child: Icon(Icons.vertical_align_center, size: 80)),
        Colors.blue[600]),
    MiniInfoPage(
        'Design your own binary contract by dragging the cut-off in the payout graph. Once you\'re done, hit the lock switch to keep your selected payout structure in place. Once locked, touch each bar to view the exact payout.',
        Transform.scale(
            scale: 1.8,
            child: Switch(
              value: false,
              onChanged: (value) {},
            )),
        Colors.grey[600]),
    MiniInfoPage(
      'You can also tap the reverse icon to flip the directionality of the cut-off.',
      Icon(Icons.loop, size: 80),
      Colors.grey[700],
    ),
  ]);

  InfoBox customInfo = InfoBox(title: 'Custom contract', pages: [
    MiniInfoPage(
        'A custom contract gives you full autonomy to design your own payout structure. Drag each bar on the payout graph up and down to create your desired payout. ',
        Icon(Icons.bar_chart, size: 80),
        Colors.blue[600]),
    MiniInfoPage(
        'Hit the lock switch to keep your selected payout structure in place. Once locked, touch each bar to view the exact payout.',
        Transform.scale(
            scale: 1.8,
            child: Switch(
              value: false,
              onChanged: (value) {},
            )),
        Colors.grey[600]),
  ]);

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    updateState = Future.wait(<Future>[
      widget.market.getCurrentHoldings(),
      widget.market.getHistoricalHoldings(),
    ]);

    _tabController!.addListener(() {
      selected = _tabController!.index;
      setState(() {
        if (selected == 0 || selected == 1) {
          locked = true;
        } else {
          locked = false;
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  void _updateBars(Offset position) {
    if (locked) {
      return;
    }

    if (selected == 0 || selected == 1) {
      return;
    }

    if (selected == 2) {
      double ii = n! * (position.dx - graphPadding) / graphWidth!;
      Array p2 = Array.fromList(range(n!).map((int i) => i > ii ? (reversed ? 10.0 : 0.0) : (reversed ? 0.0 : 10.0)).toList());
      if (reversed) {
        p2[n! - 1] = 10;
      } else {
        p2[0] = 10;
      }
      if (p2 == qs![2]) {
        return;
      } else {
        setState(() {
          qs![2] = p2;
        });
      }
    } else if (selected == 3) {
      int x = (n! * (position.dx - graphPadding) / graphWidth!).floor();
      if (x < 0) {
        x = 0;
      } else if (x > n! - 1) {
        x = n!;
      }
      double y = 10 * (1 - (position.dy - 20) / (graphHeight + 20));

      if (y < 0) {
        y = 0;
      }
      if (y > 10) {
        y = 10;
      }
      Array p2 = Array.fromList(range(n!).map((int i) => i == x ? y : qs![3][i]).toList());

      if (p2 == qs![3]) {
        return;
      } else {
        setState(() {
          qs![3] = p2;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (graphWidth == null) {
      graphWidth = MediaQuery.of(context).size.width - 2 * graphPadding;
    }
    if (qs == null) {
      n = widget.market.currentLMSR!.vecLen;

      qs = [
        Array.fromList(range(n!).map((i) => 10 * math.exp(-(n! - i - 1) / 6)).toList()),
        Array.fromList(range(n!).map((i) => 10 * math.exp(-i / 6)).toList()),
        Array.fromList(range(n!).map((int i) => i > 5 ? (reversed ? 10.0 : 0.0) : (reversed ? 0.0 : 10.0)).toList()),
        Array.fromList(range(n!).map((i) => math.sin(2 * i / n! * math.pi) + 1).toList()).scale(5)
      ];
    }

    Color background = fromHex(widget.market.colours![0]);
    Color? textColor = background.computeLuminance() > 0.5 ? Colors.grey[700] : Colors.white;

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
            controller: _tabController,
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
                Transform.rotate(angle: 3.14159 / 2, child: Icon(Icons.vertical_align_center, size: 20, color: Colors.blue[800])),
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
                Container(child: CachedNetworkImage(imageUrl: widget.market.imageURL!, height: 50)),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.market.name!, style: TextStyle(fontSize: 23.0, color: textColor)),
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
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    updateState = Future.wait(<Future>[
                      widget.market.getCurrentHoldings(),
                      widget.market.getHistoricalHoldings(),
                      Future.delayed(Duration(seconds: 2))
                    ]);
                  });
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      TeamPageHeader(qs![selected], widget.market, <InfoBox>[longInfo, shortInfo, binaryInfo, customInfo][selected],
                          <String>['Long', 'Short', 'Binary', 'Custom'][selected]),
                      GestureDetector(
                        onVerticalDragStart: (DragStartDetails details) {
                          _updateBars(details.localPosition);
                        },
                        onVerticalDragUpdate: (DragUpdateDetails details) {
                          _updateBars(details.localPosition);
                        },
                        onTapDown: (TapDownDetails details) {
                          _updateBars(details.localPosition);
                        },
                        onPanUpdate: (DragUpdateDetails details) {
                          _updateBars(details.localPosition);
                        },
                        child: AnimatedBuilder(
                            animation: _tabController!.animation!,
                            builder: (BuildContext context, Widget? child) {
                              int g1 = _tabController!.previousIndex;
                              int g2 = _tabController!.index;
                              double pcComplete = (g1 == g2) ? 0 : (_tabController!.animation!.value - g1) / (g2 - g1);
                              Array q = qs![g1].scale(1 - pcComplete) + qs![g2].scale(pcComplete);

                              return PayoutGraph(q: q, tappable: locked, padding: graphPadding, height: graphHeight);
                            }),
                      ),
                      //                 Row(
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: graphPadding, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Switch(
                                  value: locked,
                                  onChanged: (selected == 0 || selected == 1)
                                      ? null
                                      : (bool val) {
                                          setState(() {
                                            locked = val;
                                          });
                                        },
                                ),
                                Text(
                                  'Lock payout',
                                  style: TextStyle(color: (selected == 0 || selected == 1) ? Colors.grey[600] : Colors.grey[850]),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.loop),
                                  onPressed: (selected == 2)
                                      ? () {
                                          setState(() {
                                            reversed = !reversed;
                                            qs![2] = qs![2].apply((i) => 10 - i);
                                          });
                                        }
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Text(
                                    'Reverse',
                                    style: TextStyle(color: (selected == 2) ? Colors.grey[850] : Colors.grey[600]),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      TabbedPriceGraph(
                        priceHistory: widget.market.historicalLMSR!.getHistoricalValue(qs![selected]),
                        times: widget.market.historicalLMSR!.ts,
                      ),
                      SizedBox(height: 30),
                      PageFooter(widget.market)
                    ],
                  ),
                ),
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

class PlayerDetails extends StatefulWidget {
  final Market market;
  PlayerDetails(this.market);

  @override
  _PlayerDetailsState createState() => _PlayerDetailsState();
}

class _PlayerDetailsState extends State<PlayerDetails> with SingleTickerProviderStateMixin {
  Future<void>? updateState;
  TabController? _tabController;
  int selected = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController!.addListener(() {
      setState(() {
        selected = _tabController!.index;
      });
    });

    updateState = Future.wait(<Future>[
      widget.market.getCurrentHoldings(),
      widget.market.getHistoricalHoldings(),
      widget.market.getTeamInfo(),
    ]);
  }

  InfoBox longInfo(BuildContext context) {
    return InfoBox(title: 'Long contract', pages: [
      MiniInfoPage(
          'A long contract pays out more and more the better a player performs relative to other players in their league. At season end, the top ranked player will receive a payout of £10 and lowest £0.',
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.signal_cellular_alt, size: 80),
              Text(
                ' 3    2    1',
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
          Colors.blue[600]),
      MiniInfoPage(
          'This makes the long a great buy if you believe a player\'s potential is underestimated. The more the player outperforms relative to expectations, the more your asset will climb in value.',
          Icon(Icons.trending_up, size: 80),
          Colors.green[600]),
      MiniInfoPage(
          'Only the top 200 players from the previous season are included in the ranking, which is why you will find some players are missing. With 200 possible finishing positions, and a payout of £0-£10, that means a player\'s value increases by 5p for each position they rise in the ranking. ',
          Container(),
          Colors.blue[600]),
      MiniInfoPage(
          'The ranking is calculated using a scoring system that takes into account goals, saves, cards and more. To see the full break down of how the points are calculated click the button below.',
          OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
                  return PointsExplainer();
                }));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Points calculation \n explained',
                  textAlign: TextAlign.center,
                ),
              )),
          Colors.blue[600]),
    ]);
  }

  InfoBox shortInfo(BuildContext context) {
    return InfoBox(title: 'Short contract', pages: [
      MiniInfoPage(
          'A short contract pays out more and more the worse a player performs relative to other players in their league. At season end, the top ranked player will receive a payout of £0 and lowest £10.',
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform(
                  alignment: Alignment.center, transform: Matrix4.rotationY(math.pi), child: Icon(Icons.signal_cellular_alt, size: 80)),
              Text(
                '200  199  198',
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
          Colors.blue[600]),
      MiniInfoPage(
          'This makes the short a great buy if you believe a player\'s potential is overestimated. The more the player underperforms relative to expectations, the more your asset will climb in value.',
          Icon(Icons.trending_down, size: 80),
          Colors.red[600]),
      MiniInfoPage(
          'Only the top 200 players from the previous season are included in the ranking, which is why you will find some players are missing. With 200 possible finishing positions, and a payout of £0-£10, that means a player\'s value increases by 5p for each position they fall in the ranking. ',
          Container(),
          Colors.blue[600]),
      MiniInfoPage(
          'The ranking is calculated using a scoring system that takes into account goals, saves, cards and more. To see the full break down of how the points are calculated click the button below.',
          OutlinedButton(
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Points calculation \n explained',
                  textAlign: TextAlign.center,
                ),
              )),
          Colors.blue[600]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Color background = fromHex(widget.market.colours![0]);
    Color? textColor = background.computeLuminance() > 0.5 ? Colors.grey[700] : Colors.white;
    return DefaultTabController(
      length: 2,
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
            controller: _tabController,
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
                Container(child: CachedNetworkImage(imageUrl: widget.market.imageURL!, height: 50)),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.market.name!, style: TextStyle(fontSize: 23.0, color: textColor)),
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
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    updateState = Future.wait(<Future>[
                      widget.market.getCurrentHoldings(),
                      widget.market.getHistoricalHoldings(),
                      widget.market.getTeamInfo(),
                      Future.delayed(Duration(seconds: 2))
                    ]);
                  });
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      PlayerPageHeader(selected == 0, widget.market, selected == 0 ? longInfo(context) : shortInfo(context)),
                      TabbedPriceGraph(
                          priceHistory: widget.market.historicalLMSR!.getHistoricalValue((Array.fromList(selected == 0 ? <double>[10.0, 0.0] : <double>[0.0, 1.0]))),
                          times: widget.market.historicalLMSR!.ts),
                      SizedBox(height: 10),
                      PageFooter(widget.market)
                    ],
                  ),
                ),
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

class PageFooter extends StatelessWidget {
  final Market market;

  PageFooter(this.market);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
            (market.runtimeType == TeamMarket
                ? <Widget>[
                    Container(
                      height: 60,
                      child: Center(
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
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
                : <Widget>[MarketTile(market: market.team!, returnsPeriod: 'd'), Divider(thickness: 2)]));
  }
}
