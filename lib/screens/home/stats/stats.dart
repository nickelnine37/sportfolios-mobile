import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sportfolios_alpha/utils/design/colors.dart';
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
      Future.delayed(Duration(seconds: 0)),
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

            Color background = fromHex(widget.market!.colours![0]);
            Color? textColor = background.computeLuminance() > 0.5 ? Colors.grey[700] : Colors.white;

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  flexibleSpace: Container(
                      decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [background, Colors.white],
                        begin: const FractionalOffset(0.4, 0.5),
                        end: const FractionalOffset(1, 0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  )),
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [Icon(Icons.info_outline, size: 24, color: textColor)]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Icon(Icons.history, size: 24, color: textColor)]),
                      ),
                    ],
                  ),
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  toolbarHeight: 107,
                  iconTheme: IconThemeData(color: textColor),
                  title: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                color: textColor,
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 22,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              Container(child: CachedNetworkImage(imageUrl: widget.market!.imageURL!, height: 50)),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.market!.name!, style: TextStyle(fontSize: 23.0, color: textColor)),
                                  SizedBox(height: 2),
                                  Container(
                                    height: 20, 
                                    child: infoSelected ? Text(
                                      'Details',
                                      style: TextStyle(fontSize: 15.0, color: textColor),// fontWeight: FontWeight.w400),
                                    ) : GestureDetector(
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
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(selectedSeason!, style: TextStyle(fontSize: 15.0, color: textColor)),
                                        // SizedBox(hei: 1),.
                                        Container(
                                          padding: EdgeInsets.all(0),
                                          width: 30,
                                          height: 20,
                                          child: Center(
                                            child: Icon(Icons.arrow_drop_down, color: textColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ])
                      // : Column(children: [
                      //     Row(
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       children: [
                      //         IconButton(
                      //           color: textColor,
                      //           icon: Icon(
                      //             Icons.arrow_back,
                      //             size: 22,
                      //           ),
                      //           onPressed: () {
                      //             Navigator.of(context).pop();
                      //           },
                      //         ),
                      //         Container(child: CachedNetworkImage(imageUrl: widget.market!.imageURL!, height: 50)),
                      //         SizedBox(width: 15),
                      //         Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Text(widget.market!.name!, style: TextStyle(fontSize: 23.0, color: textColor)),
                      //             SizedBox(height: 2),
                      //             GestureDetector(
                      //               onTap: () async {
                      //                 String? newlySelectedSeason = await showDialog(
                      //                   context: context,
                      //                   builder: (context) {
                      //                     return SeasonSelectorDialogue(seasons);
                      //                   },
                      //                 );
                      //                 if (newlySelectedSeason != null && newlySelectedSeason != selectedSeason) {
                      //                   setState(() {
                      //                     selectedSeason = newlySelectedSeason;
                      //                   });
                      //                 }
                      //               },
                      //               child: Row(
                      //                 crossAxisAlignment: CrossAxisAlignment.end,
                      //                 children: [
                      //                   Text(selectedSeason!, style: TextStyle(fontSize: 15.0, color: textColor)),
                      //                   // SizedBox(hei: 1),.
                      //                   Container(
                      //                     padding: EdgeInsets.all(0),
                      //                     width: 30,
                      //                     height: 20,
                      //                     child: Center(
                      //                       child: Icon(Icons.arrow_drop_down, color: textColor),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ]),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    conditional_string == 'T' ? TeamDetails(widget.market!) : PlayerDetails(widget.market!),
                    conditional_string == 'T' ? TeamHistory(widget.market!, new_season!) : PlayerHistory(widget.market!, new_season!)
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
