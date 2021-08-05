import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/objects/markets.dart';
import '../../../utils/widgets/dialogues.dart';

class StatsShow extends StatefulWidget {
  final Market? market;
  final String initialSeason;

  StatsShow(this.market, this.initialSeason);

  @override
  _StatsShowState createState() => _StatsShowState();
}

class _StatsShowState extends State<StatsShow>
    with SingleTickerProviderStateMixin {
  Future<void>? statsFuture;
  String? selectedSeason;
  List<String>? seasons;
  String? conditional_string;

  TabController? _tabController;
  bool infoSelected = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        infoSelected = _tabController!.index == 0;
      });
    });
    statsFuture = Future.wait([
      widget.market!.getStats(),
      Future.delayed(Duration(seconds: 2)),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    if (_tabController != null) {
      _tabController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: statsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (seasons == null) {
              seasons = widget.market!.stats!.keys.toList();
              seasons!.sort();
            }

            if (selectedSeason == null) {
              selectedSeason = seasons!.last;
            }

            Map<String, dynamic>? new_season =
                widget.market!.stats![selectedSeason!];

            conditional_string = widget.market.toString();
            conditional_string = conditional_string!.substring(
                conditional_string!.length - 2, conditional_string!.length - 1);

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 20, color: Colors.white)
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.history, size: 20, color: Colors.white)
                            ]),
                      ),
                    ],
                  ),
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  toolbarHeight: 100,
                  iconTheme: IconThemeData(color: Colors.white),
                  title: infoSelected
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    color: Colors.white,
                                    icon: Icon(
                                      Icons.arrow_back,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                          child: CachedNetworkImage(
                                              imageUrl:
                                                  widget.market!.imageURL!,
                                              height: 50)),
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.market!.name!,
                                            style: TextStyle(
                                                fontSize: 23.0,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                      child: CachedNetworkImage(
                                          imageUrl: conditional_string == 'T'
                                              ? new_season!['season_logo']
                                                  .toString()
                                              : new_season!['league_url']
                                                  .toString(),
                                          height: 50)),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    color: Colors.white,
                                    icon: Icon(
                                      Icons.arrow_back,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                          child: CachedNetworkImage(
                                              imageUrl:
                                                  widget.market!.imageURL!,
                                              height: 50)),
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              String? newlySelectedSeason =
                                                  await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return SeasonSelectorDialogue(
                                                      seasons);
                                                },
                                              );
                                              if (newlySelectedSeason != null &&
                                                  newlySelectedSeason !=
                                                      selectedSeason) {
                                                setState(() {
                                                  selectedSeason =
                                                      newlySelectedSeason;
                                                });
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Text(selectedSeason!,
                                                    style: TextStyle(
                                                        fontSize: 23.0,
                                                        color: Colors.white)),
                                                SizedBox(height: 2),
                                                Container(
                                                  padding: EdgeInsets.all(0),
                                                  width: 30,
                                                  height: 20,
                                                  child: Center(
                                                    child: Icon(
                                                        Icons.arrow_drop_down,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(widget.market!.name!,
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                      child: CachedNetworkImage(
                                          imageUrl: conditional_string == 'T'
                                              ? new_season!['season_logo']
                                                  .toString()
                                              : new_season!['league_url']
                                                  .toString(),
                                          height: 50)),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    conditional_string == 'T'
                        ? TeamDetails(widget.market!)
                        : PlayerDetails(widget.market!),
                    conditional_string == 'T'
                        ? TeamStats(widget.market!, new_season)
                        : PlayerStats(widget.market!, new_season)
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(snapshot.error as String)),
            );
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }
}

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

class TeamStats extends StatelessWidget {
  final Market market;
  final Map<String, dynamic> new_season;

  const TeamStats(this.market, this.new_season);

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

class PlayerStats extends StatelessWidget {
  final Market market;
  final Map<String, dynamic> new_season;

  const PlayerStats(this.market, this.new_season);

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
