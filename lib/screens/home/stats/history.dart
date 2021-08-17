import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/home/stats/tables.dart';
import '../../../data/objects/markets.dart';

class TeamHistory extends StatefulWidget {
  final Market market;
  final String selectedSeason;

  const TeamHistory(this.market, this.selectedSeason);

  @override
  _TeamHistoryState createState() => _TeamHistoryState();
}

class _TeamHistoryState extends State<TeamHistory> {
  Future<void>? tableFuture;
  Map<String, Map>? tableData;
  int? sid;
  Map<int, String> leagueMap = {
    8: 'Premier League',
    9: 'Championship',
    501: 'Premiership',
    564: 'La Liga',
    301: 'Bundesliga',
    82: 'Ligue 1',
    384: 'Serie A',
  };

  @override
  void initState() {
    super.initState();
    tableFuture = getTable();
  }

  Future<void> getTable() async {
    sid = widget.market.stats![widget.selectedSeason]!['season_id'];
    tableData = Map<String, Map>.from((await FirebaseFirestore.instance.collection('tables').doc('${sid}T').get()).data()!);
  }

  @override
  Widget build(BuildContext context) {
    if (sid != widget.market.stats![widget.selectedSeason]!['season_id']) {
      tableFuture = getTable();
    }

    return FutureBuilder(
        future: tableFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(height: 10), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 15), 
                    Container(
                      child: CachedNetworkImage(imageUrl: widget.market.stats![widget.selectedSeason]!['league_image']),
                      height: 50,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leagueMap[widget.market.stats![widget.selectedSeason]!['league_id']]!,
                          style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                        ),
                        Text(
                          widget.selectedSeason,
                          style: TextStyle(fontSize: 17, color: Colors.grey[800]),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 10),
                TeamTable(table: tableData!, teamId: widget.market.id),
                SizedBox(height: 20),
              ],
            ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

class PlayerHistory extends StatelessWidget {
  final Market market;
  final Map<String, dynamic> new_season;

  const PlayerHistory(this.market, this.new_season);

  @override
  Widget build(BuildContext context) {
    return market.details!['position'] == 'goalkeeper'
        ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DataTable(columns: [
                      DataColumn(
                        label: Text(
                          'Saves',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          new_season['saves'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                      )
                    ], rows: [
                      DataRow(cells: [
                        DataCell(Text(
                          'Inside box saves',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['inside_box_saves'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Penalty saves',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['penalty_saves'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Cleansheets',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['cleansheets'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points'] == null
                            ? Text('0')
                            : Text(
                                new_season['points'].toString(),
                                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                              ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points per game',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points_per_game'] == null
                            ? Text('0')
                            : Text(
                                new_season['points_per_game'].toString(),
                                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                              ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Rank',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['ranking'] == null
                            ? Text('0')
                            : Text(
                                new_season['ranking'].toString(),
                                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                              ))
                      ]),
                    ]),
                  ),
                ],
              ),
            ),
          )
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DataTable(columns: [
                      DataColumn(
                        label: Text(
                          'Goals',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          new_season['goals'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                      )
                    ], rows: [
                      DataRow(cells: [
                        DataCell(Text(
                          'Assists',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['assists'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Shots',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['shots'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Shots on goal',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['shots_on_goal'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Crosses',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['crosses'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Accurate passes',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['accurate_passes'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Fouls drawn',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['fouls_drawn'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Fouls conceded',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['fouls_conceded'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Interceptions',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['interceptions'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Yellow cards',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['yellow_cards'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Red cards',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['red_cards'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Cleansheets',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['cleansheets'].toString(),
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points'] == null
                            ? Text('0')
                            : Text(
                                new_season['points'].toString(),
                                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                              ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points per game',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points_per_game'] == null
                            ? Text('0')
                            : Text(
                                new_season['points_per_game'].toString(),
                                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                              ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points per minute',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points_per_minute'] == null
                            ? Text('0')
                            : Text(
                                new_season['points_per_minute'].toString(),
                                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                              ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Rank',
                          style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['ranking'] == null
                            ? Text('0')
                            : Text(
                                new_season['ranking'].toString(),
                                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                              ))
                      ]),
                    ]),
                  ),
                ],
              ),
            ),
          );
  }
}
