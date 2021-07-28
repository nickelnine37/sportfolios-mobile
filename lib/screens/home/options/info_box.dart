import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/numerical/array_operations.dart';

class InfoBox extends StatelessWidget {
  final String title;
  final List<Widget> pages;

  InfoBox({
    required this.title,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    const double padding = 30;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 200,
        height: 400,
        padding: EdgeInsets.only(top: padding, left: padding, right: padding),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(padding),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
        ),
        child: DefaultTabController(
          length: pages.length,
          child: Center(
            child: Column(children: [
              Text(
                title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              Container(
                width: 80,
                child: Center(
                  child: TabBar(
                    labelColor: Colors.grey[900],
                    unselectedLabelColor: Colors.grey[400],
                    indicatorColor: Colors.grey[700],
                    indicatorWeight: 0.0001,
                    labelPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: range(pages.length).map((int i) => Tab(child: Text('•', style: TextStyle(fontSize: 20)))).toList(),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: pages,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text('OK'),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class MiniInfoPage extends StatelessWidget {
  final String text;
  final Widget icon;
  final Color? iconColor;

  MiniInfoPage(this.text, this.icon, this.iconColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        Shimmer.fromColors(
            period: Duration(milliseconds: 3000), baseColor: iconColor!, highlightColor: iconColor!.withAlpha(120), child: icon)
      ],
    );
  }
}

class PointsExplainer extends StatelessWidget {
  const PointsExplainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              'Player points explained',
              style: TextStyle(color: Colors.white),
            )),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(children: [
              Text(
                '   In each league there are 200 elligible players which have been chosen based on their performance in the previous season. In SportFolios you can trade contracts which pay out based on the relative ranking of these 200 players in the current season. ',
                style: TextStyle(color: Colors.grey[850], fontSize: 15),
              ),
              SizedBox(height: 15), 
              Text (
                '   The rank of these players is determined using a scoring system. Points are assigned to players for their in-game performance in a similar way to fantasy football. The full break-down of our scoring system in shown in the table below. ',
                style: TextStyle(color: Colors.grey[850], fontSize: 15),
              ),
              SizedBox(height: 15),
              Center(
                  child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Event',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Points',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                rows: const <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For playing up to 60 minutes')),
                      DataCell(Text('1')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For playing 60 minutes or more (excluding stoppage time)')),
                      DataCell(Text('2')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For each goal scored by a goalkeeper or defender')),
                      DataCell(Text('6')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For each goal scored by a midfielder')),
                      DataCell(Text('5')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For each goal scored by a forward')),
                      DataCell(Text('4')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For each goal assist')),
                      DataCell(Text('3')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For a clean sheet by a goalkeeper or defender')),
                      DataCell(Text('4')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For a clean sheet by a midfielder')),
                      DataCell(Text('1')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For every 3 shot saves by a goalkeeper')),
                      DataCell(Text('1')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For each penalty save')),
                      DataCell(Text('5')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For each penalty miss')),
                      DataCell(Text('-2')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For every 2 goals conceded by a goalkeeper or defender')),
                      DataCell(Text('-1')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For each yellow card')),
                      DataCell(Text('-1')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For each red card')),
                      DataCell(Text('-3')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('For each own goal')),
                      DataCell(Text('-2')),
                    ],
                  ),
                ],
              )),
              SizedBox(height: 15),
              Text('   Where there is a tie for points between two players, it is broken by points-per minute played.'),
              SizedBox(height: 15), 
              Text('   If during the season a player is transferred to a team compteting in the same league, their points total carries over and all contracts remain valid. If however they tansfer to a different league, any contracts will be terminated and a full refund of the original price paid will be provided. '),
              SizedBox(height: 15), 
              Text('   If a player has an injury during a season that stops them from playing temporarily, this has no effect on the validity of the contract. However if they are incopacitated or die, the contract will be voided and money returned. For every player that leaves the 200, an additional player will be aded in. '),
            ]),
          ),
        ));
  }
}
