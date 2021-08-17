import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/objects/leagues.dart';
import 'tables.dart';
import '../../../data/objects/markets.dart';

class TeamCurrentDetails extends StatelessWidget {
  final Market market;
  final League league;

  TeamCurrentDetails(this.market, this.league);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        SixGrid(titles: [
          'Short Code',
          'Founded',
          'Average Age',
          'Home Ground',
          'Capacity',
          'City'
        ], values: [
          market.details!['short_code'].toString(),
          market.details!['founded'].toString(),
          market.details!['player_age'].toString() + ' years',
          market.details!['stadium'].toString(),
          market.details!['capacity'].toString(),
          market.details!['city'].toString(),
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Manager: '),
              Text(market.details!['manager'] + '  ' + market.details!['manager_country']),
              SizedBox(
                  child: CachedNetworkImage(
                    imageUrl: market.details!['manager_image'],
                  ),
                  width: 40,
                  height: 40),
            ],
          ),
        ),
        TeamTable(table: league.teamTable!, marketId: market.id),
        SizedBox(height: 20),
        TeamStatsTable(market.currentStats!),
      ]),
    );
  }
}

class PlayerCurrentDetails extends StatelessWidget {
  final Market market;
  final League league;

  const PlayerCurrentDetails(this.market, this.league);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SixGrid(
            titles: [
              'Full Name',
              'Nationality',
              'Birth date',
              'Position',
              'Height',
              'Weight',
            ],
            values: [
              market.details!['fullname'].toString(),
              market.details!['nationality'].toString(),
              market.details!['birthdate'].toString(),
              market.details!['position'].toString(),
              market.details!['height'].toString(),
              market.details!['weight'].toString(),
            ],
          ),
          PlayerTable(league.playerTable!, market.id)
        ],
      ),
    );
  }
}
