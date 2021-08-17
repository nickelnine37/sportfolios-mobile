import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/home/market_tile.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';
import 'package:sportfolios_alpha/utils/strings/number_format.dart';
import 'package:sportfolios_alpha/utils/strings/string_utils.dart';

class SixGrid extends StatelessWidget {
  final List<String> titles;
  final List<String> values;
  SixGrid({required this.titles, required this.values});

  TableRow bottomLine(List<String> data) {
    return TableRow(
      children: range(3)
          .map(
            (i) => Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 10),
              child: Text(
                data[i],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow topLine(List<String> titles) {
    return TableRow(
      children: range(3)
          .map(
            (i) => Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 3),
              child: Text(
                titles[i],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w400, fontSize: 12),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow tableRow(List<String> titles, List<String> data) {
    return TableRow(
      children: [
        Table(
          border: TableBorder(verticalInside: BorderSide(color: Colors.grey[400]!)),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[topLine(titles), bottomLine(data)],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 30, right: 30, bottom: 10),
      child: Table(
        border: TableBorder.all(color: Colors.grey[400]!),
        children: [
          tableRow(titles.sublist(0, 3), values.sublist(0, 3)),
          tableRow(titles.sublist(3), values.sublist(3)),
        ],
      ),
    );
  }
}

class TeamTable extends StatefulWidget {
  final Map<String, Map> table;
  final String marketId;

  const TeamTable({required this.table, required this.marketId});

  @override
  _TeamTableState createState() => _TeamTableState();
}

class _TeamTableState extends State<TeamTable> {
  bool _ascending = true;
  List<MapEntry>? table;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (table == null) {
      table = widget.table.entries.toList();
      table!.sort((MapEntry t1, MapEntry t2) => t1.value['position'].compareTo(t2.value['position']));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: DataTable(
        columnSpacing: 15,
        dataRowHeight: 40,
        sortColumnIndex: 0,
        horizontalMargin: 5,
        sortAscending: _ascending,
        columns: [
          DataColumn(
              label: Text('#'),
              numeric: false,
              onSort: (columnIndex, i) {
                setState(() {
                  _ascending = !_ascending;
                  if (_ascending) {
                    table!.sort((MapEntry t1, MapEntry t2) => t1.value['position'].compareTo(t2.value['position']));
                  } else {
                    table!.sort((MapEntry t1, MapEntry t2) => t2.value['position'].compareTo(t1.value['position']));
                  }
                });
              }),
          DataColumn(label: Text('PV'), numeric: false),
          DataColumn(label: Text('Team'), numeric: false),
          DataColumn(label: Text('P'), numeric: true),
          DataColumn(label: Text('GD'), numeric: true),
          DataColumn(label: Text('PTS'), numeric: true),
        ],
        rows: table!.map<DataRow>((MapEntry team) {
          return DataRow(cells: [
            DataCell(Text(
              team.value['position'].toString(),
              style: TextStyle(fontSize: 13),
            )),
            DataCell(Text(
              formatCurrency(10 * exp(-(team.value['position'] - 1) / 6), 'GBP'),
              style: TextStyle(fontSize: 13),
            )),
            DataCell(
              Row(
                children: [
                  SizedBox(
                    child: CachedNetworkImage(imageUrl: team.value['image_url']),
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    splitLongName(team.value['name'], 17, 'team'),
                    style: TextStyle(fontSize: 13),
                  )
                ],
              ),
            ),
            DataCell(
              Text(
                team.value['played'].toString(),
                style: TextStyle(fontSize: 13),
              ),
            ),
            DataCell(
              Text(
                "${team.value['goal_difference'] > 0 ? '+' : '-'}${team.value['goal_difference'].abs()}",
                style: TextStyle(fontSize: 13),
              ),
            ),
            DataCell(
              Text(
                team.value['points'].toString(),
                style: TextStyle(fontSize: 13),
              ),
            ),
          ], selected: team.key == widget.marketId.split(':')[0]);
        }).toList(),
      ),
    );
  }
}

class PlayerTable extends StatefulWidget {
  final Map<String, Map> fullTable;
  final String marketId;

  PlayerTable(this.fullTable, this.marketId);

  @override
  _PlayerTableState createState() => _PlayerTableState();
}

class _PlayerTableState extends State<PlayerTable> {
  List<MapEntry>? sortedTable;

  @override
  Widget build(BuildContext context) {
    if (sortedTable == null) {
      sortedTable = widget.fullTable.entries.toList();
      sortedTable!.sort((MapEntry t1, MapEntry t2) => t1.value['position'].compareTo(t2.value['position']));
    }

    return DefaultTabController(
      initialIndex: (widget.fullTable[widget.marketId.split(':')[0]]!['position'] - 1) ~/ 25,
      length: 8,
      child: Column(
        children: [
          Container(
            height: 1070,
            child: TabBarView(
              children: range(8)
                  .map<Widget>(
                    (int i) => PlayerTableSection(
                      tableSection: sortedTable!.sublist(25 * i, 25 * (i + 1)),
                      marketId: widget.marketId,
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            height: 25,
            width: 200,
            color: Colors.grey[200],
            // decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
            child: TabBar(
              labelColor: Colors.grey[800],
              unselectedLabelColor: Colors.grey[400],
              indicatorColor: Colors.grey[600],
              indicatorWeight: 1,
              labelPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(child: Text('1', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                Tab(child: Text('2', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                Tab(child: Text('3', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                Tab(child: Text('4', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                Tab(child: Text('5', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                Tab(child: Text('6', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                Tab(child: Text('7', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                Tab(child: Text('8', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PlayerTableSection extends StatelessWidget {
  final List<MapEntry> tableSection;
  final String marketId;

  const PlayerTableSection({required this.tableSection, required this.marketId});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DataTable(
        columnSpacing: 15,
        dataRowHeight: 40,
        horizontalMargin: 5,
        columns: [
          DataColumn(label: Text('#'), numeric: false),
          DataColumn(label: Text('PV'), numeric: false),
          DataColumn(label: Text('TM'), numeric: false),
          DataColumn(label: Text('Player'), numeric: false),
          DataColumn(label: Text('PTS'), numeric: true),
          DataColumn(label: Text('PPM'), numeric: true),
        ],
        rows: tableSection.map<DataRow>((MapEntry player) {
          return DataRow(cells: [
            DataCell(Text(
              player.value['position'].toString(),
              style: TextStyle(fontSize: 13),
            )),
            DataCell(Text(
              formatCurrency((200 - player.value['position'] + 1) * 0.05, 'GBP'),
              style: TextStyle(fontSize: 13),
            )),
            DataCell(
              SizedBox(
                child: CachedNetworkImage(imageUrl: player.value['team_image_url']),
                width: 20,
                height: 20,
              ),
            ),
            DataCell(
              Row(
                children: [
                  SizedBox(
                    child: CachedNetworkImage(imageUrl: player.value['image_url']),
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    splitLongName(player.value['name'], 12, 'player'),
                    style: TextStyle(fontSize: 13),
                    overflow: TextOverflow.fade,
                  )
                ],
              ),
            ),
            DataCell(
              Text(
                player.value['points'].toString(),
                style: TextStyle(fontSize: 13),
              ),
            ),
            DataCell(
              Text(
                player.value['points_per_minute'].toString(),
                style: TextStyle(fontSize: 13),
              ),
            ),
          ], selected: player.key == marketId.split(':')[0]);
        }).toList(),
      ),
    );
  }
}

class TeamStatsTable extends StatelessWidget {
  final Map statsTable;
  final List<String> homeAwayStats = [
    'win',
    'lost',
    'draw',
    'goals_for',
    'goals_against',
    'avg_goals_per_game_scored',
    'avg_goals_per_game_conceded',
    'clean_sheet',
    'failed_to_score',
  ];

  final Map<String, String> homeAwayStatsTitles = {
    'win': 'Won',
    'lost': 'Lost',
    'draw': 'Drew',
    'goals_for': 'Goals For',
    'goals_against': 'Goals Against',
    'avg_goals_per_game_scored': 'Goals Scored per Game',
    'avg_goals_per_game_conceded': 'Goals Conceded per Game',
    'clean_sheet': 'Clean Sheets',
    'failed_to_score': 'Failed to Score',
  };

  TeamStatsTable(this.statsTable);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DataTable(
        dataRowHeight: 80,
        columnSpacing: 15,
        horizontalMargin: 20,
        columns: [
          DataColumn(label: Text('Stat'), numeric: false),
          DataColumn(label: Text('Value'), numeric: true),
        ],
        rows: homeAwayStats
            .map(
              (String stat) => DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            homeAwayStatsTitles[stat]!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text('       Home'),
                          Text('       Away'),
                          Text('       Total'),
                        ],
                      ),
                    ),
                    DataCell(
                      Column(
                        children: [
                          SizedBox(height: 5),
                          Text(''),
                          SizedBox(height: 5),
                          Text(statsTable[stat]['home'].toString()),
                          Text(statsTable[stat]['away'].toString()),
                          Text(statsTable[stat]['total'].toString()),
                        ],
                      ),
                    ),
                  ],
                  color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                    // Even rows will have a grey color.
                    if (homeAwayStats.indexOf(stat).isEven) {
                      return Colors.grey.withOpacity(0.15);
                    }
                    return null; // Use default value for other states and odd rows.
                  })),
            )
            .toList(),
      ),
    );
  }
}
