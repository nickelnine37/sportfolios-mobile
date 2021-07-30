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
          print(snapshot);
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

            if (conditional_string == 'T') {
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
                                Icon(Icons.history,
                                    size: 20, color: Colors.white)
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
                                            // Flexible(
                                            //   child: RichText(
                                            //     overflow: TextOverflow.ellipsis,
                                            //     strutStyle: StrutStyle(fontSize: 23.0),
                                            //     text: TextSpan(
                                            //         style: TextStyle(color: Colors.white),
                                            //         text: widget.market!.name!),
                                            //   ),
                                            // ),
                                            // Flexible(
                                            //     child: Text(widget.market!.name!, style: TextStyle(
                                            //         fontSize: 23.0,
                                            //         color: Colors.white),
                                            //   overflow: TextOverflow.ellipsis),
                                            // ),
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
                                            imageUrl: new_season!['season_logo']
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
                                                if (newlySelectedSeason !=
                                                        null &&
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
                                            imageUrl: new_season!['season_logo']
                                                .toString(),
                                            height: 50)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  body: infoSelected
                      ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                children: [
                                  Column(children: [Text('My Account')]),
                                  Column(children: [Text('Settings')]),
                                ],
                              ),
                            ],
                          ),
                      )
                      : Row(
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Align(
                                      child: Text(
                                        'Wins',
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            height: 2,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Text(
                                      'Draws',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          height: 2,
                                          fontSize: 20),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Text(
                                      'Losses',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          height: 2,
                                          fontSize: 20),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Text(
                                      'Goals for',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          height: 2,
                                          fontSize: 20),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Text(
                                      'Goals against',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          height: 2,
                                          fontSize: 20),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Text(
                                      'Goal difference',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          height: 2,
                                          fontSize: 20),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25.0),
                                    child: Text(
                                      'Points',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          height: 2,
                                          fontSize: 20),
                                    ),
                                  ),
                                ]),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  padding: const EdgeInsets.only(left: 140.0),
                                  child: Text(
                                    new_season['wins'].toString(),
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        height: 2,
                                        fontSize: 20),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  padding: const EdgeInsets.only(left: 140.0),
                                  child: Text(
                                    new_season['draws'].toString(),
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        height: 2,
                                        fontSize: 20),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  padding: const EdgeInsets.only(left: 140.0),
                                  child: Text(
                                    new_season['losses'].toString(),
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        height: 2,
                                        fontSize: 20),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  padding: const EdgeInsets.only(left: 140.0),
                                  child: Text(
                                    new_season['goals_for'].toString(),
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        height: 2,
                                        fontSize: 20),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  padding: const EdgeInsets.only(left: 140.0),
                                  child: Text(
                                    new_season['goals_against'].toString(),
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        height: 2,
                                        fontSize: 20),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  padding: const EdgeInsets.only(left: 140.0),
                                  child: Text(
                                    (new_season['goals_for'] -
                                            new_season['goals_against'])
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        height: 2,
                                        fontSize: 20),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  padding: const EdgeInsets.only(left: 140.0),
                                  child: Text(
                                    new_season['points'].toString(),
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        height: 2,
                                        fontSize: 20),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                ),
              );
            } else if (conditional_string == 'P') {
              return DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    bottom: TabBar(
                      controller: _tabController,
                      tabs: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.history,
                                    size: 20, color: Colors.white)
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.info_outline,
                                    size: 20, color: Colors.white)
                              ]),
                        ),
                      ],
                    ),
                    automaticallyImplyLeading: false,
                    titleSpacing: 0,
                    toolbarHeight: 100,
                    iconTheme: IconThemeData(color: Colors.white),
                    title: infoSelected
                        ? Text('Hey')
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                  Container(
                                      child: CachedNetworkImage(
                                          imageUrl: widget.market!.imageURL!,
                                          height: 50)),
                                  SizedBox(width: 15),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(selectedSeason!,
                                            style: TextStyle(
                                                fontSize: 23.0,
                                                color: Colors.white)),
                                        SizedBox(height: 2),
                                        Text(widget.market!.name!,
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.white)),
                                      ]),
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
                                          selectedSeason = newlySelectedSeason;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(0),
                                      width: 30,
                                      height: 20,
                                      child: Center(
                                        child: Icon(Icons.arrow_drop_down,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      child: CachedNetworkImage(
                                          imageUrl: new_season!['league_url']
                                              .toString(),
                                          height: 50)),
                                ],
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
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Goals',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Assists',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Shots',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Shots on goal',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Crosses',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Accurate passes',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Fouls drawn',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Fouls conceded',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Tackles',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Interceptions',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Yellow cards',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Red cards',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(
                                child: Text(
                                  'Cleansheets',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 2,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                          ]),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season!['goals'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['assists'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['shots'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['shots_on_goal'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['crosses'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['accurate_passes'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['fouls_drawn'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['fouls_conceded'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['tackles'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['interceptions'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['yellow_cards'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['red_cards'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(left: 140.0),
                            child: Text(
                              new_season['cleansheets'].toString(),
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 2,
                                  fontSize: 20),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(),
                body: Center(child: Text('Error')),
              );
            }
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
