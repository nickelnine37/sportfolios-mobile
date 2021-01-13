import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data_models/leagues.dart';
import 'package:sportfolios_alpha/utils/dialogues.dart';
import 'package:sportfolios_alpha/utils/marquee.dart';
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 150,
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
              Container(child: Image.network(league.imageURL, height: 50)),
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(league.name, style: TextStyle(fontSize: 28.0, color: Colors.white)),
                      Container(
                        padding: EdgeInsets.all(0),
                        width: 30,
                        height: 20,
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                            onPressed: () async {
                              int i = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return LeagueSelectorDialogue(widget.leagues);
                                  });
                              if (i != null) {
                                setState(() {
                                  selectedLeague = i;
                                });
                              }
                            },
                            padding: EdgeInsets.all(0),
                          ),
                        ),
                      ),
                    ],
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
    );
  }
}



class LeagueProgressBar extends StatelessWidget {
  final League league;

  const LeagueProgressBar(this.league);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
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
