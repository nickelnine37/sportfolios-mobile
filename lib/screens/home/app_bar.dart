import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../data/objects/leagues.dart';
import 'market_scroll.dart';
import '../../utils/widgets/dialogues.dart';

class MainView extends StatefulWidget {
  final List<League> leagues;
  final String sport;
  final GlobalKey<ScaffoldState> drawerKey;
  final initialLeagueId;

  MainView({
    required this.sport,
    required this.leagues,
    required this.initialLeagueId,
    required this.drawerKey,
  });

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int? selectedLeagueId;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _getPrefs();
  }

  Future<void> _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedLeagueId == null) {
      if (widget.initialLeagueId == null) {
        selectedLeagueId = widget.leagues[0].leagueID;
      } else {
        selectedLeagueId = widget.initialLeagueId;
      }
    }

    League league = widget.leagues.firstWhere((leagueElement) => leagueElement.leagueID == selectedLeagueId);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          toolbarHeight: 145,
          bottom: TabBar(
            labelPadding: EdgeInsets.all(5),
            tabs: <Row>[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Teams', style: TextStyle(fontSize: 15.0, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.groups, size: 24, color: Colors.white)
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Players', style: TextStyle(fontSize: 15.0, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.person, size: 20, color: Colors.white)
              ]),
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
                    widget.drawerKey.currentState!.openDrawer();
                  },
                ),
                Container(child: CachedNetworkImage(imageUrl: league.imageURL!, height: 50)),
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        int? newlySelectedLeague = await showDialog(
                          context: context,
                          builder: (context) {
                            return LeagueSelectorDialogue(widget.leagues);
                          },
                        );
                        if (newlySelectedLeague != null && newlySelectedLeague != selectedLeagueId) {
                          prefs.setInt('selectedLeague', newlySelectedLeague);
                          setState(() {
                            selectedLeagueId = newlySelectedLeague;
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(league.name!, style: TextStyle(fontSize: 28.0, color: Colors.white)),
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
                      league.countryFlagEmoji! + '  ' + league.country!,
                      style: TextStyle(fontSize: 13.0, color: Colors.white),
                    )
                  ],
                ),
              ],
            ),
            LeagueProgressBar(leagueOrMarket: league),
          ]),
        ),
        body: TabBarView(
          children: [
            MarketScroll(league: league, marketType: 'teams'),
            // MarketScroll(league, 'teams'),
            MarketScroll(league: league, marketType:'players'),
            // MarketScroll(league, 'players'),
          ],
        ),
      ),
    );
  }

  // Row _makeTab(String text, bool up) {
  //   Icon upArrow = Icon(
  //     Icons.trending_up,
  //     size: 20,
  //     color: Colors.green[600],
  //   );
  //   Icon downArrow = Icon(
  //     Icons.trending_down,
  //     size: 20,
  //     color: Colors.red[600],
  //   );

  // return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
  //   Text(text, style: TextStyle(fontSize: 14.0, color: Colors.white)),
  //   up ? upArrow : downArrow
  // ]);
  // }

}

class LeagueProgressBar extends StatelessWidget {
  final dynamic leagueOrMarket;
  final Color textColor;
  final Color paintColor1;
  final Color paintColor2;

  const LeagueProgressBar(
      {this.leagueOrMarket,
      this.textColor = Colors.white,
      this.paintColor1 = Colors.blue,
      this.paintColor2 = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 18),
        Container(
            width: double.infinity,
            child:
                CustomPaint(painter: LeagueProgressBarPainter(leagueOrMarket, this.paintColor1, this.paintColor2))),
        SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(DateFormat('d MMM yy').format(leagueOrMarket.startDate),
              style: TextStyle(fontSize: 14.0, color: textColor)),
          Text(DateFormat('d MMM yy').format(leagueOrMarket.endDate),
              style: TextStyle(fontSize: 14.0, color: textColor))
        ]),
      ]),
    );
  }
}

class LeagueProgressBarPainter extends CustomPainter {
  final dynamic leagueOrMarket;
  final Color paintColor1;
  final Color paintColor2;

  LeagueProgressBarPainter(this.leagueOrMarket, this.paintColor1, this.paintColor2);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintProgress = Paint()
      ..color = paintColor1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    Paint paintRemaining = Paint()
      ..color = paintColor2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    int now;
    
    if (DateTime.now().millisecondsSinceEpoch > leagueOrMarket.endDate.millisecondsSinceEpoch) {
      now = leagueOrMarket.endDate.millisecondsSinceEpoch;
    }
    else if (DateTime.now().millisecondsSinceEpoch < leagueOrMarket.startDate.millisecondsSinceEpoch) {
      now = leagueOrMarket.startDate.millisecondsSinceEpoch;
    }
    else {
      now = DateTime.now().millisecondsSinceEpoch;
    }

    double fractionComplete =
        (now - leagueOrMarket.startDate.millisecondsSinceEpoch) /
            (leagueOrMarket.endDate.millisecondsSinceEpoch - leagueOrMarket.startDate.millisecondsSinceEpoch);

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
