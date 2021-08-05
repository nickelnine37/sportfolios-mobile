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
  PortfolioFetcher? portfolioFetcher;

  @override
  void initState() {
    super.initState();
    portfolioFetcher = ReturnsPortfolioFetcher('d');
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
                  child: Center(child: Text("Sorry, no results :'(")),
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
  }

  @override
  bool get wantKeepAlive => true;
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
