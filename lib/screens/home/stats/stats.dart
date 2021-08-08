import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/objects/markets.dart';
import '../../../utils/widgets/dialogues.dart';
import 'details.dart';
import 'history.dart';

class StatsShow extends StatefulWidget {
  final Market? market;
  final String initialSeason;

  StatsShow(this.market, this.initialSeason);

  @override
  _StatsShowState createState() => _StatsShowState();
}

class _StatsShowState extends State<StatsShow> with SingleTickerProviderStateMixin {
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

            Map<String, dynamic>? new_season = widget.market!.stats![selectedSeason!];

            conditional_string = widget.market.toString();
            conditional_string = conditional_string!.substring(conditional_string!.length - 2, conditional_string!.length - 1);

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
                            children: [Icon(Icons.info_outline, size: 20, color: Colors.white)]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [Icon(Icons.history, size: 20, color: Colors.white)]),
                      ),
                    ],
                  ),
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  toolbarHeight: 100,
                  iconTheme: IconThemeData(color: Colors.white),
                  title: infoSelected
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                  SizedBox(width: 10),
                                  Container(child: CachedNetworkImage(imageUrl: widget.market!.imageURL!, height: 50)),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.market!.name!,
                                        style: TextStyle(fontSize: 23.0, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                  child: CachedNetworkImage(
                                      imageUrl: conditional_string == 'T'
                                          ? new_season!['season_logo'].toString()
                                          : new_season!['league_url'].toString(),
                                      height: 50)),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                  SizedBox(width: 10),
                                  Container(child: CachedNetworkImage(imageUrl: widget.market!.imageURL!, height: 50)),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          String? newlySelectedSeason = await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return SeasonSelectorDialogue(seasons);
                                            },
                                          );
                                          if (newlySelectedSeason != null && newlySelectedSeason != selectedSeason) {
                                            setState(() {
                                              selectedSeason = newlySelectedSeason;
                                            });
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Text(selectedSeason!, style: TextStyle(fontSize: 23.0, color: Colors.white)),
                                            SizedBox(height: 2),
                                            Container(
                                              padding: EdgeInsets.all(0),
                                              width: 30,
                                              height: 20,
                                              child: Center(
                                                child: Icon(Icons.arrow_drop_down, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(widget.market!.name!, style: TextStyle(fontSize: 13.0, color: Colors.white)),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                  child: CachedNetworkImage(
                                      imageUrl: conditional_string == 'T'
                                          ? new_season!['season_logo'].toString()
                                          : new_season!['league_url'].toString(),
                                      height: 50)),
                            ],
                          ),
                        ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    conditional_string == 'T' ? TeamDetails(widget.market!) : PlayerDetails(widget.market!),
                    conditional_string == 'T' ? TeamHistory(widget.market!, new_season) : PlayerHistory(widget.market!, new_season)
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
