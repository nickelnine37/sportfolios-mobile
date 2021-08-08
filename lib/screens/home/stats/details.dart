
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/objects/markets.dart';

class TeamDetails extends StatelessWidget {
  final Market market;

  const TeamDetails(this.market);

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
                // Cole final edits
                DataColumn(
                  label: Text(
                    'Home ground',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                // Cole final edits
                DataColumn(
                  label: Container(
                      child: Text(
                        market.details!['home_ground'].toString(),
                        style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                        softWrap: true,
                      ),
                      width: 150),
                )
              ], rows: [
                DataRow(cells: [
                  DataCell(Text(
                    'Capacity',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    market.details!['capacity'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'City',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    market.details!['city'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Founded',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    market.details!['founded'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Surface',
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  )),
                  DataCell(Text(
                    market.details!['surface'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ))
                ]),
              ]),
            ),
            // Cole final edits
            SizedBox(height: 25), 
            market.details!['image_path'] == null
                ? Text('')
                : CachedNetworkImage(
                    imageUrl: market.details!['image_path'].toString(),
                    height: 220)
          ],
        ),
      ),
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
                    'Birth country: \n' +
                        market.details!['birthcountry'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Birth date: \n' + market.details!['birthdate'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ], rows: [
                DataRow(cells: [
                  DataCell(Text(
                    'Height: \n' + market.details!['height'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700], height: 1.5, fontSize: 14),
                  )),
                  DataCell(Text(
                    'Weight: \n' + market.details!['weight'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700], height: 1.5, fontSize: 14),
                  ))
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    'Nationality: \n' +
                        market.details!['nationality'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700], height: 1.5, fontSize: 14),
                  )),
                  DataCell(Text(
                    'Position: \n' + market.details!['position'].toString(),
                    style: TextStyle(
                        color: Colors.grey[700], height: 1.5, fontSize: 14),
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
