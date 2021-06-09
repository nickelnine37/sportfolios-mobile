import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';
import 'package:sportfolios_alpha/utils/dialogues.dart';

class StatsShow extends StatefulWidget {
  final Market market;
  final String initialSeasonId;

  StatsShow(this.market, this.initialSeasonId);

  @override
  _StatsShowState createState() => _StatsShowState();
}

class _StatsShowState extends State<StatsShow> {
  Future<void> statsFuture;
  String selectedSeasonId;
  List<String> seasons;

  @override
  void initState() {
    super.initState();
    statsFuture = Future.wait([
      widget.market.getStats(),
      Future.delayed(Duration(seconds: 2)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: statsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (seasons == null) {
              seasons = widget.market.stats.keys.toList();
              seasons.sort();
            }

            if (selectedSeasonId == null) {
              selectedSeasonId = seasons.last;
            }

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String newlySelectedLeague = await showDialog(
                          context: context,
                          builder: (context) {
                            return SeasonSelectorDialogue(seasons);
                          },
                        );
                        if (newlySelectedLeague != null &&
                            newlySelectedLeague != selectedSeasonId) {
                          setState(() {
                            selectedSeasonId = newlySelectedLeague;
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(selectedSeasonId,
                              style: TextStyle(
                                  fontSize: 28.0, color: Colors.white)),
                          Container(
                            padding: EdgeInsets.all(0),
                            width: 30,
                            height: 20,
                            child: Center(
                              child: Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: Center(child: Text(widget.market.stats[selectedSeasonId].keys.toString())),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(snapshot.error)),
            );
          } else {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}
