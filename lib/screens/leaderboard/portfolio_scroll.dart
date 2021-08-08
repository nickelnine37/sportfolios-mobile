import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportfolios_alpha/data/firebase/portfolios.dart';
import '../../data/objects/portfolios.dart';
import 'leaderboard.dart';
import 'portfolio_tile.dart';

class GlobalLeaderboardScroll extends StatefulWidget {
  @override
  _GlobalLeaderboardScrollState createState() => _GlobalLeaderboardScrollState();
}

class _GlobalLeaderboardScrollState extends State<GlobalLeaderboardScroll> with AutomaticKeepAliveClientMixin {
  Future<void>? portfoliosFuture;
  List<Portfolio>? portfolios;
  ScrollController _scrollController = ScrollController(initialScrollOffset: 50);
  TextEditingController _textController = TextEditingController();

  PortfolioFetcher? portfolioFetcherInUse;
  ReturnsPortfolioFetcher returnsPortfolioFetcher = ReturnsPortfolioFetcher('M');
  String returnsPeriod = 'M';
  // PortfolioFetcher? searchPortfolioFetcher;

  @override
  void initState() {
    super.initState();
    portfolioFetcherInUse = returnsPortfolioFetcher;
    portfoliosFuture = portfolioFetcherInUse!.get10();
    _scrollController.addListener(_scrollListener);
  }

  bool _scrolledToBottom() {
    return _scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange;
  }

  void _scrollListener() async {
    if (!portfolioFetcherInUse!.finished) {
      if (_scrolledToBottom()) {
        await portfolioFetcherInUse!.get10();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: portfoliosFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // make space for the apology tile

          int nTiles = portfolioFetcherInUse!.loadedResults.length + 2;

          if (nTiles == 2) {
            nTiles += 1;
          }

          return ListView.separated(
            controller: _scrollController,
            itemCount: nTiles,
            itemBuilder: (context, index) {

              if (index == 0) {
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10, bottom: 1),
                        height: 47,
                        child: TextField(
                          controller: _textController,
                          onSubmitted: (String value) async {
                            if (value.trim() != '') {
                              portfolioFetcherInUse = SearchPortfolioFetcher(value.trim().toLowerCase());
                              setState(() {
                                portfoliosFuture = portfolioFetcherInUse!.get10();
                              });
                            }
                          },
                          decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            hintText: 'Search',
                            icon: Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _textController.clear();
                                portfolioFetcherInUse = returnsPortfolioFetcher;
                                // close keyboard - not sure exactly what's going on here...
                                if (!FocusScope.of(context).hasPrimaryFocus) {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: OutlinedButton(
                        onPressed: () async {
                          String? sortBy = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SortByDialogue();
                              });

                          if (sortBy != null && sortBy != returnsPeriod) {
                            returnsPortfolioFetcher = ReturnsPortfolioFetcher(sortBy);
                            portfolioFetcherInUse = returnsPortfolioFetcher;
                            setState(() {
                              returnsPeriod = sortBy;
                              portfoliosFuture = portfolioFetcherInUse!.get10();
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.sort_sharp, color: Colors.grey[700]),
                            SizedBox(width: 8),
                            Text(
                              'Sort',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }

              if (index == 1 && portfolioFetcherInUse!.loadedResults.length == 0) {
            // no results here
            return Padding(
              padding: const EdgeInsets.all(25.0),
              child: Center(child: Text("Sorry, no results :'(")),
            );
          }

              if (index == nTiles - 1) {
                // final tile contains the loading spinner
                if (portfolioFetcherInUse!.finished || (portfolioFetcherInUse!.loadedResults.length == 0)) {
                  return Container(height: 0);
                } else {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              } else {
                return PortfolioTile(
                  portfolio: portfolioFetcherInUse!.loadedResults[index - 1
                  ],
                  returnsPeriod: returnsPeriod,
                  index: index - 1,
                );
              }
            },
            separatorBuilder: (context, index) => Divider(
              thickness: 2,
              height: 2,
            ),
          );
        } else {
          // loading is not done
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SortByDialogue extends StatelessWidget {
  final List<String> options = [
    'Value',
    '24h return',
    'Week return',
    'Month return',
  ];

  final List<String> sortBy = [
    'M',
    'd',
    'w',
    'm',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 412,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
        ),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('Sort by', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Container(
              height: 340,
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text(options[i]),
                    // leading: Container(
                    // width: 35,
                    // height: 35,
                    // child: CachedNetworkImage(imageUrl: leagues[i].imageURL!),
                    // ),
                    // trailing: Text(options[i]),
                    onTap: () {
                      Navigator.of(context).pop(sortBy[i]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LikedLeaderboardScroll extends StatefulWidget {
  @override
  _LikedLeaderboardScrollState createState() => _LikedLeaderboardScrollState();
}

class _LikedLeaderboardScrollState extends State<LikedLeaderboardScroll> with AutomaticKeepAliveClientMixin {
  Future<void>? portfoliosFuture;
  List<Portfolio>? portfolios;
  ScrollController _scrollController = ScrollController(initialScrollOffset: 50);
  FavoritesPortfolioFetcher? portfolioFetcher;
  List<String> likedPortfolios = [];

  @override
  void initState() {
    super.initState();
    // empty at start
    // portfolioFetcher = FavoritesPortfolioFetcher(portfolioIds: likedPortfolios);
    // immediate completion
    // portfoliosFuture = portfolioFetcher!.get10();
    _scrollController.addListener(_scrollListener);
  }

  bool _scrolledToBottom() {
    return _scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange;
  }

  void _scrollListener() async {
    if (!portfolioFetcher!.finished) {
      if (_scrolledToBottom()) {
        await portfolioFetcher!.get10();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer(
      builder: (context, watch, child) {
        List<String> newLikedPortfolios = watch(likedPortfolioProvider).portfolios;
        portfolioFetcher = FavoritesPortfolioFetcher(portfolioIds: newLikedPortfolios);
        portfoliosFuture = portfolioFetcher!.get10();

        return FutureBuilder(
          future: portfoliosFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print('results: ${portfolioFetcher!.loadedResults}');
              int nTiles = portfolioFetcher!.loadedResults.length + 1;
              // make space for the apology tile
              if (nTiles == 1) {
                nTiles += 1;
              }

              return ListView.separated(
                controller: _scrollController,
                itemCount: nTiles,
                itemBuilder: (context, index) {
                  if (index == nTiles - 1) {
                    // final tile contains the loading spinner
                    if (portfolioFetcher!.finished || (portfolioFetcher!.loadedResults.length == 0)) {
                      return Container(height: 0);
                    } else {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  }
                  if (portfolioFetcher!.loadedResults.length == 0) {
                    // no results here
                    return Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Center(
                          child: Text(
                        "Add some portfolios to your favourites - you'll see them appear here!",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )),
                    );
                  } else {
                    return PortfolioTile(
                      portfolio: portfolioFetcher!.loadedResults[index],
                      returnsPeriod: 'd',
                      index: index,
                    );
                  }
                },
                separatorBuilder: (context, index) => Divider(
                  thickness: 2,
                  height: 2,
                ),
              );
            } else {
              // loading is not done
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MarketContainedPortfolioScroll extends StatefulWidget {
  final String marketId;

  MarketContainedPortfolioScroll(this.marketId);

  @override
  _MarketContainedPortfolioScrollState createState() => _MarketContainedPortfolioScrollState();
}

class _MarketContainedPortfolioScrollState extends State<MarketContainedPortfolioScroll> with AutomaticKeepAliveClientMixin {
  Future<void>? portfoliosFuture;
  List<Portfolio>? portfolios;
  ScrollController _scrollController = ScrollController(initialScrollOffset: 50);

  PortfolioFetcher? portfolioFetcher;

  @override
  void initState() {
    super.initState();
    portfolioFetcher = ContainingPortfolioFetcher(widget.marketId);
    portfoliosFuture = portfolioFetcher!.get10();
    _scrollController.addListener(_scrollListener);
  }

  bool _scrolledToBottom() {
    return _scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange;
  }

  void _scrollListener() async {
    if (!portfolioFetcher!.finished) {
      if (_scrolledToBottom()) {
        await portfolioFetcher!.get10();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: portfoliosFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // make space for the apology tile

          int nTiles = portfolioFetcher!.loadedResults.length + 1;

          if (nTiles == 1) {
            nTiles += 1;
          }

          return ListView.separated(
            controller: _scrollController,
            itemCount: nTiles,
            itemBuilder: (context, index) {
              
              if (index == 0 && portfolioFetcher!.loadedResults.length == 0) {
                // no results here
                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(child: Text("Sorry, no results :'(")),
                );
              }

              if (index == nTiles - 1) {
                // final tile contains the loading spinner
                if (portfolioFetcher!.finished || (portfolioFetcher!.loadedResults.length == 0)) {
                  return Container(height: 0);
                } else {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              } else {
                return PortfolioTile(
                  portfolio: portfolioFetcher!.loadedResults[index],
                  returnsPeriod: 'M',
                  index: index,
                );
              }
            },
            separatorBuilder: (context, index) => Divider(
              thickness: 2,
              height: 2,
            ),
          );
        } else {
          // loading is not done
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
