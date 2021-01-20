import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data_models/leagues.dart';
import 'package:sportfolios_alpha/screens/home/contract_scroll.dart';
import 'package:sportfolios_alpha/utils/dialogues.dart';
// import 'package:sportfolios_alpha/utils/marquee.dart';
import 'package:intl/intl.dart';

class MainView extends StatefulWidget {
  final List<League> leagues;
  final String sport;
  final GlobalKey<ScaffoldState> drawerKey;

  MainView({@required this.sport, @required this.leagues, @required this.drawerKey});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int selectedLeague = 0;

  @override
  Widget build(BuildContext context) {
    League league = widget.leagues[selectedLeague];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          toolbarHeight: 145,
          bottom: TabBar(
            labelPadding: EdgeInsets.all(5),
            tabs: <Row>[
              _makeTab('Teams', true),
              _makeTab('Teams', false),
              _makeTab('Players', true),
              _makeTab('Players', false),
            ],
          ),
          title: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    widget.drawerKey.currentState.openDrawer();
                  },
                ),
                Container(child: CachedNetworkImage(imageUrl: league.imageURL, height: 50)),
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        int i = await showDialog(
                          context: context,
                          builder: (context) {
                            return LeagueSelectorDialogue(widget.leagues);
                          },
                        );
                        if (i != null && i != selectedLeague) {
                          setState(() {
                            selectedLeague = i;
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(league.name, style: TextStyle(fontSize: 28.0, color: Colors.white)),
                          Container(
                            padding: EdgeInsets.all(0),
                            width: 30,
                            height: 20,
                            child: Center(
                              child: Icon(Icons.arrow_drop_down, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      league.countryFlagEmoji + '  ' + league.country,
                      style: TextStyle(fontSize: 13.0, color: Colors.white),
                    )
                  ],
                ),
              ],
            ),
            LeagueProgressBar(league),
          ]),
        ),
        body: TabBarView(
          children: [
            ContractScroll(league, 'team_long'),
            ContractScroll(league, 'team_short'),
            ContractScroll(league, 'player_long'),
            ContractScroll(league, 'player_short'),
          ],
        ),
      ),
    );
  }

  Row _makeTab(String text, bool up) {
    Icon upArrow = Icon(
      Icons.trending_up,
      size: 20,
      color: Colors.green[600],
    );
    Icon downArrow = Icon(
      Icons.trending_down,
      size: 20,
      color: Colors.red[600],
    );

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Text(text, style: TextStyle(fontSize: 14.0, color: Colors.white)),
      up ? upArrow : downArrow
    ]);
  }
}

class LeagueProgressBar extends StatelessWidget {
  final League league;

  const LeagueProgressBar(this.league);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 18),
        Container(width: double.infinity, child: CustomPaint(painter: LeagueProgressBarPainter(league))),
        SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(DateFormat('d MMM yy').format(league.startDate),
              style: TextStyle(fontSize: 14.0, color: Colors.white)),
          Text(DateFormat('d MMM yy').format(league.endDate),
              style: TextStyle(fontSize: 14.0, color: Colors.white))
        ]),
      ]),
    );
  }
}

class LeagueProgressBarPainter extends CustomPainter {
  final League league;
  LeagueProgressBarPainter(this.league);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintProgress = Paint()
      ..color = Colors.blue[600]
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    Paint paintRemaining = Paint()
      ..color = Colors.grey[600]
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    double fractionComplete =
        (DateTime.now().millisecondsSinceEpoch - league.startDate.millisecondsSinceEpoch) /
            (league.endDate.millisecondsSinceEpoch - league.startDate.millisecondsSinceEpoch);

    Path pathProgress = Path();
    pathProgress.moveTo(0, size.height / 2);
    pathProgress.lineTo(size.width * fractionComplete, size.height / 2);

    Path pathRemaining = Path();
    pathRemaining.moveTo(size.width * fractionComplete, size.height / 2);
    pathRemaining.lineTo(size.width, size.height / 2);

    canvas.drawPath(pathProgress, paintProgress);
    canvas.drawPath(pathRemaining, paintRemaining);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
