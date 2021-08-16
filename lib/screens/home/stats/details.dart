import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';
import '../../../data/objects/markets.dart';

class TeamDetails extends StatelessWidget {
  final Market market;

  final List<String> topRowTitles = ['Short Code', 'City', 'Founded'];
  final List<String> topRowData = ['short_code', 'city', 'founded'];
  final List<String> lowerRowTitles = ['Home Ground', 'Capacity', 'Surface'];
  final List<String> lowerRowData = ['home_ground', 'capacity', 'surface'];

  TeamDetails(this.market);

  TableRow bottomLine(List<String> data) {
    return TableRow(
      children: range(3)
          .map(
            (i) => Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 10),
              child: Text(
                market.details![data[i]].toString(),
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

  TableRow tableRow(List<String> data, List<String> titles) {
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
    print(market.details);
    return SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Table(
            border: TableBorder.all(color: Colors.grey[400]!),
            children: [tableRow(topRowData, topRowTitles), tableRow(lowerRowData, lowerRowTitles)],
          ),
        )
      ]),
    );
  }
}

class PlayerDetails extends StatelessWidget {
  final Market market;

  const PlayerDetails(this.market);

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
                    'Birth country: \n' + market.details!['birthcountry'].toString(),
                    style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Birth date: \n' + market.details!['birthdate'].toString(),
                    style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                ),
              ], rows: [
                DataRow(cells: [
                  DataCell(Text(
                    'Height: \n' + market.details!['height'].toString(),
                    style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
                  )),
                  DataCell(Text(
                    'Weight: \n' + market.details!['weight'].toString(),
                    style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Nationality: \n' + market.details!['nationality'].toString(),
                    style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
                  )),
                  DataCell(Text(
                    'Position: \n' + market.details!['position'].toString(),
                    style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
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
