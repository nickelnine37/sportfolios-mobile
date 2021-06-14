import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

            Map<String, dynamic> new_season =
                widget.market.stats[selectedSeasonId];

            return Scaffold(
              appBar: AppBar(
              
                iconTheme: IconThemeData(color: Colors.white),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String newlySelectedSeason = await showDialog(
                          context: context,
                          builder: (context) {
                            return SeasonSelectorDialogue(seasons);
                          },
                        );
                        if (newlySelectedSeason != null &&
                            newlySelectedSeason != selectedSeasonId) {
                          setState(() {
                            selectedSeasonId = newlySelectedSeason;
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // IconButton(
                          //   color: Colors.white,
                          //   icon: Icon(
                          //     Icons.arrow_back,
                          //     size: 22,
                          //   ),
                          //   onPressed: () {
                          //     Navigator.of(context).pop();
                          //   },
                          // ),
                          Container(
                              child: CachedNetworkImage(
                                  imageUrl: widget.market.imageURL,
                                  height: 50)),
                          SizedBox(width: 15),
                          Column(children: [
                            Text(selectedSeasonId,
                                style: TextStyle(
                                    fontSize: 23.0, color: Colors.white)),
                            SizedBox(height: 2),
                            Text(widget.market.name,
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.white)),
                          ]),
                          Container(
                            padding: EdgeInsets.all(0),
                            width: 30,
                            height: 20,
                            child: Center(
                              child: Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                            ),
                          ),
                          Container(
                              child: CachedNetworkImage(
                                  imageUrl: new_season['season_logo'].toString(),
                                  height: 50)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: Row(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Align(
                            child: Text(
                              'Wins',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            'Draws',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                height: 2,
                                fontSize: 20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            'Losses',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                height: 2,
                                fontSize: 20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            'Goals for',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                height: 2,
                                fontSize: 20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            'Goals against',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                height: 2,
                                fontSize: 20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            'Goal difference',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                height: 2,
                                fontSize: 20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            'Points',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                height: 2,
                                fontSize: 20),
                          ),
                        ),
                      ]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        padding: const EdgeInsets.only(left: 140.0),
                        child: Text(
                          new_season['wins'].toString(),
                          style: TextStyle(height: 2, fontSize: 20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        padding: const EdgeInsets.only(left: 140.0),
                        child: Text(
                          new_season['draws'].toString(),
                          style: TextStyle(height: 2, fontSize: 20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        padding: const EdgeInsets.only(left: 140.0),
                        child: Text(
                          new_season['losses'].toString(),
                          style: TextStyle(height: 2, fontSize: 20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        padding: const EdgeInsets.only(left: 140.0),
                        child: Text(
                          new_season['goals_for'].toString(),
                          style: TextStyle(height: 2, fontSize: 20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        padding: const EdgeInsets.only(left: 140.0),
                        child: Text(
                          new_season['goals_against'].toString(),
                          style: TextStyle(height: 2, fontSize: 20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        padding: const EdgeInsets.only(left: 140.0),
                        child: Text(
                          (new_season['goals_for'] -
                                  new_season['goals_against'])
                              .toString(),
                          style: TextStyle(height: 2, fontSize: 20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        padding: const EdgeInsets.only(left: 140.0),
                        child: Text(
                          new_season['points'].toString(),
                          style: TextStyle(height: 2, fontSize: 20),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(snapshot.error)),
            );
          } else {
            return Scaffold(
              // appBar: AppBar(),
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}
