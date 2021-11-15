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
                    // Container(
                    //   child: CachedNetworkImage(imageUrl: widget.market.stats![widget.selectedSeason]!['league_image']),
                    //   height: 50,
                    // ),
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
                TeamTable(table: tableData!, marketId: widget.market.id),
                SizedBox(height: 20),
                TeamStatsTable(widget.market.stats![widget.selectedSeason]!)
              ],
            ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

class PlayerHistory extends StatefulWidget {
  final Market market;
  final String selectedSeason;

  const PlayerHistory(this.market, this.selectedSeason);

  @override
  _PlayerHistoryState createState() => _PlayerHistoryState();
}

class _PlayerHistoryState extends State<PlayerHistory> {
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
    tableData = Map<String, Map>.from((await FirebaseFirestore.instance.collection('tables').doc('${sid}P').get()).data()!);
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
                    // Container(
                    //   child: CachedNetworkImage(imageUrl: widget.market.stats![widget.selectedSeason]!['league_image']),
                    //   height: 50,
                    // ),
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
                PlayerTable(tableData!, widget.market.id),
                PlayerStatsTable(widget.market.stats![widget.selectedSeason]!),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
