import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportfolios_alpha/data/models/leagues.dart';
import 'package:sportfolios_alpha/screens/home/contract_scroll.dart';
import 'package:sportfolios_alpha/utils/dialogues.dart';
import 'package:intl/intl.dart';

class MainView extends StatefulWidget {
  final List<League> leagues;
  final String sport;
  final GlobalKey<ScaffoldState> drawerKey;
  final initialLeagueId;

  MainView({
    @required this.sport,
    @required this.leagues,
    @required this.initialLeagueId,
    @required this.drawerKey,
  });

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int selectedLeagueId;
  SharedPreferences prefs;

  @override
  void initState() { 
    super.initState();
    _getPrefs();
  }

  Future<void> _getPrefs() async {
    prefs =  await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {

    if (selectedLeagueId == null) {
      if (widget.initialLeagueId == null) {
        selectedLeagueId = widget.leagues[0].leagueID;
      }
      else {
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
            tabs: <Text>[
              Text('Teams', style: TextStyle(fontSize: 15.0, color: Colors.white)),
              Text('Players', style: TextStyle(fontSize: 15.0, color: Colors.white))
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
                        int newlySelectedLeague = await showDialog(
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
            LeagueProgressBar(league: league),
          ]),
        ),
        body: TabBarView(
          children: [
            ContractScroll(league, 'teams'),
            // ContractScroll(league, 'teams'),
            ContractScroll(league, 'players'),
            // ContractScroll(league, 'players'),
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
  final League league;
  final Color textColor;
  final Color paintColor1;
  final Color paintColor2;

  const LeagueProgressBar({this.league, this.textColor=Colors.white, this.paintColor1=Colors.blue, this.paintColor2=Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 18),
        Container(width: double.infinity, child: CustomPaint(painter: LeagueProgressBarPainter(league, this.paintColor1, this.paintColor2))),
        SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(DateFormat('d MMM yy').format(league.startDate),
              style: TextStyle(fontSize: 14.0, color: textColor)),
          Text(DateFormat('d MMM yy').format(league.endDate),
              style: TextStyle(fontSize: 14.0, color: textColor))
        ]),
      ]),
    );
  }
}

class LeagueProgressBarPainter extends CustomPainter {
  final League league;
  final Color paintColor1;
  final Color paintColor2;

  LeagueProgressBarPainter(this.league, this.paintColor1, this.paintColor2);

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
