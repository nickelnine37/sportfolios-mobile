import 'package:flutter/material.dart';
import './leaderboard_widgets/pie_chart.dart';
import './leaderboard_widgets/pie_data.dart';
import './leaderboard_widgets/leaderboard_plots.dart';

/// The portfolio leaderboard page!
/// TODO: Implement!
class Leaderboard extends StatefulWidget {
  Leaderboard({Key key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final List<SegmentData> pieData = PieData().data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Text(
                    '1h',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  icon: Text(
                    '1d',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  icon: Text(
                    '1w',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  icon: Text(
                    '1m',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  icon: Text(
                    'Max',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            title: Text('Leaderboard'),
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Container(
                          child: Text(
                            '1',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          padding: EdgeInsets.all(10.0),
                        ),
                        Container(
                          child: Icon(
                            Icons.favorite,
                            color: Colors.green,
                            size: 65.0,
                            semanticLabel:
                                'Text to announce in accessibility modes',
                          ),
                          padding: EdgeInsets.only(right: 10.0),
                        ),
                        Column(
                          children: [
                            Container(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('TequilaFan21',
                                    style: TextStyle(fontSize: 20)),
                              ),
                              padding: EdgeInsets.all(2.0),
                              width: 180,
                            ),
                            Container(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Liverpool',
                                    style: TextStyle(fontSize: 16)),
                              ),
                              padding: EdgeInsets.all(2.0),
                              width: 180,
                            ),
                            Container(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('21-03-21',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              padding: EdgeInsets.all(2.0),
                              width: 180,
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          // Pie Chart holder
                          child: MiniDonutChart(pieData),
                          padding: EdgeInsets.only(right: 10),
                          // child: Text('Hello'),
                        ),
                      ],
                    ),
                    color: Colors.white,
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(0),
                    width: double.infinity,
                  ),
                  Container(
                    child: HomeWidget(),
                  ),
                  Divider(
                    thickness: 2,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  Text('Text 2'),
                  Text('Text 3'),
                ],
              ),
              Text('Returns over 1 day for overall leaders!'),
              Text('Returns over 1 week for overall leaders!'),
              Text('Returns over 1 month for overall leaders!'),
              Text('Returns over season for overall leaders!'),
            ],
          ),
        ),
      ),
    );
  }
}
