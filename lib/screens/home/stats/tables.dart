import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';

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
  final String teamId;

  const TeamTable({required this.table, required this.teamId});

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
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DataTable(
        columnSpacing: 15,
        dataRowHeight: 40,
        sortColumnIndex: 0,
        horizontalMargin: 5,
        sortAscending: _ascending,
        columns: [
          DataColumn(
              label: Text('#'),
              numeric: true,
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
          DataColumn(label: Text('Team'), numeric: false),
          DataColumn(label: Text('P'), numeric: true),
          DataColumn(label: Text('GD'), numeric: true),
          DataColumn(label: Text('PTS'), numeric: true),
        ],
        rows: table!.map<DataRow>((MapEntry team) {
          return DataRow(cells: [
            DataCell(Text(team.value['position'].toString())),
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
                    team.value['name'],
                    style: TextStyle(fontSize: 13),
                  )
                ],
              ),
            ),
            DataCell(Text(team.value['played'].toString())),
            DataCell(Text("${team.value['goal_difference'] > 0 ? '+' : '-'}${team.value['goal_difference'].abs()}")),
            DataCell(Text(team.value['points'].toString())),
          ], selected: team.key == widget.teamId.split(':')[0]);
        }).toList(),
      ),
    );
  }
}
