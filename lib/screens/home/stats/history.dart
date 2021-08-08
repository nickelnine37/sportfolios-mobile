
import 'package:flutter/material.dart';
import '../../../data/objects/markets.dart';

class TeamHistory extends StatelessWidget {
  final Market market;
  final Map<String, dynamic> new_season;

  const TeamHistory(this.market, this.new_season);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DataTable(columns: [
                DataColumn(
                  label: Text(
                    'Table position',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                DataColumn(
                  label: Text(
                    new_season['ranking'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                )
              ], rows: [
                DataRow(cells: [
                  DataCell(Text(
                    'Wins',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    new_season['wins'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Draws',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    new_season['draws'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Losses',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    new_season['losses'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Goals for',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    new_season['goals_for'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Goals against',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    new_season['goals_against'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Goal difference',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    (new_season['goals_for'] - new_season['goals_against'])
                        .toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Points',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    new_season['points'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
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
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          new_season['saves'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    ], rows: [
                      DataRow(cells: [
                        DataCell(Text(
                          'Inside box saves',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['inside_box_saves'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Penalty saves',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['penalty_saves'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Cleansheets',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['cleansheets'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points'] == null ? Text('0') : Text(
                          new_season['points'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points per game',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points_per_game'] == null ? Text('0') : Text(
                          new_season['points_per_game'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Rank',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['ranking'] == null ? Text('0') : Text(
                          new_season['ranking'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
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
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          new_season['goals'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    ], rows: [
                      DataRow(cells: [
                        DataCell(Text(
                          'Assists',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['assists'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Shots',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['shots'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Shots on goal',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['shots_on_goal'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Crosses',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['crosses'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Accurate passes',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['accurate_passes'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Fouls drawn',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['fouls_drawn'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Fouls conceded',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['fouls_conceded'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Interceptions',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['interceptions'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Yellow cards',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['yellow_cards'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Red cards',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['red_cards'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Cleansheets',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        DataCell(Text(
                          new_season['cleansheets'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points'] == null ? Text('0') : Text(
                          new_season['points'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points per game',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points_per_game'] == null ? Text('0') : Text(
                          new_season['points_per_game'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Points per minute',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['points_per_minute'] == null ? Text('0') : Text(
                          new_season['points_per_minute'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Rank',
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        )),
                        // Cole final edits
                        DataCell(new_season['ranking'] == null ? Text('0') : Text(
                          new_season['ranking'].toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
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
