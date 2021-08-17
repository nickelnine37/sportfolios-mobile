import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/widgets/dialogues.dart';
import '../../data/objects/leagues.dart';
import '../../data/firebase/markets.dart';
import 'market_tile.dart';
import '../../utils/strings/string_utils.dart';

/// Widget for main scroll view of markets
class MarketScroll extends StatefulWidget {
  final League? league;
  final String? marketType;
  final int? teamId;
  MarketScroll({this.league, this.marketType, this.teamId});

  @override
  State<StatefulWidget> createState() {
    return MarketScrollState();
  }
}

class MarketScrollState extends State<MarketScroll> with AutomaticKeepAliveClientMixin {
  /// [_marketsFuture] helps us load a spinner at the start, when the first 10 markets are
  /// being fetched
  Future<void>? _marketsFuture;

  /// three marketFeter-type objects:
  /// 1. [_defaultMarketFetcher]: this is responsible for getting markets when casually scrolling
  /// 2. [_searchQueryMarketFetcher]: this is responsible for getting markets when a search has been entered
  /// 3. [_selectedMarketFetcher]: this is a helper variable which just holds whichever of the above two we are
  /// currently considering.
  MarketFetcher? _defaultMarketFetcher;
  MarketFetcher? _searchQueryMarketFetcher;
  MarketFetcher? _selectedMarketFetcher;

  /// initialise scroll controller with offset to cover search bar. We also use this when
  /// checking if we've scrolled to the bottom, to load more markets
  ScrollController _scrollController = ScrollController(initialScrollOffset: 50);

  /// This is just so we can do some basic things with the enterered text like clear it
  TextEditingController _textController = TextEditingController();

  /// What we're sorting by
  // String sortBy = 'Price';
  String sortByField = 'long_price_current';
  bool sortByDescending = true;
  String returnsPeriod = 'd';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textController.dispose();
    super.dispose();
  }

  /// helper function: has the user just switched leagues on us?
  bool _justSwitchedLeagues() {
    if (widget.league == null) {
      return false;
    }
    return _defaultMarketFetcher != null && _defaultMarketFetcher!.leagueID != widget.league!.leagueID;
  }

  /// helper function: has the user scrolled to the bottom of the page?
  bool _scrolledToBottom() {
    return _scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange;
  }

  /// listener for scroll controller
  void _scrollListener() async {
    if (!_selectedMarketFetcher!.finished) {
      if (_scrolledToBottom()) {
        // await Future.delayed(Duration(seconds: 1), () => 12);
        // don't reassign the future here - it's just for the initial building
        await _selectedMarketFetcher!.get10();
        setState(() {});
      }
    }
  }

  /// 'factory reset' our page. Get a new [LeagueMarketFetcher] for the relevant league,
  void _refreshState() {
    _defaultMarketFetcher = widget.league != null
        ? LeagueMarketFetcher(
            leagueID: widget.league!.leagueID, marketType: widget.marketType, sortByField: sortByField, sortByDescending: sortByDescending)
        : TeamPlayerMarketFetcher(teamId: widget.teamId!, sortByField: sortByField, sortByDescending: sortByDescending);
    _searchQueryMarketFetcher = null;
    _selectedMarketFetcher = _defaultMarketFetcher;
    _marketsFuture = _selectedMarketFetcher!.get10();
  }

  @override
  Widget build(BuildContext context) {
    // needed for mixin
    super.build(context);

    // runs when we first load the widget or we've just switched leagues
    if (_selectedMarketFetcher == null || _justSwitchedLeagues()) {
      _refreshState();
    }

    return FutureBuilder(
      future: _marketsFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('MS1 ${snapshot.error.toString()}');
          return Center(child: Text('Error'));
        } else {
          int nTiles = _selectedMarketFetcher!.loadedResults.length + 2;
          // make space for the apology tile
          if (nTiles == 2) {
            nTiles += 1;
          }
          return ListView.separated(
            controller: _scrollController,
            itemCount: nTiles,
            itemBuilder: (context, index) {
              if (index == 0) {
                // the top tile contains the seach bar
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
                              _searchQueryMarketFetcher = widget.league != null
                                  ? LeagueSearchMarketFetcher(
                                      search: value.trim().toLowerCase(),
                                      leagueID: widget.league!.leagueID,
                                      marketType: widget.marketType,
                                      alreadyLoaded: _defaultMarketFetcher!.loadedResults)
                                  : TeamPlayerSearchMarketFetcher(
                                      search: value.trim().toLowerCase(),
                                      teamId: widget.teamId,
                                      alreadyLoaded: _defaultMarketFetcher!.loadedResults);
                              await _searchQueryMarketFetcher!.get10();
                              _selectedMarketFetcher = _searchQueryMarketFetcher;
                              setState(() {});
                            }
                          },
                          decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            hintText: formatTitle('Search'),
                            icon: Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _textController.clear();
                                _selectedMarketFetcher = _defaultMarketFetcher;
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
                          List<dynamic>? sortBy = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SortByDialogue();
                              });

                          if (sortBy != null) {
                            setState(() {
                              sortByField = sortBy[0];
                              sortByDescending = sortBy[1];
                              if (sortByField != 'long_price_current' && sortByField != 'position') {
                                returnsPeriod = sortByField[sortByField.length - 1];
                              } else {
                                returnsPeriod = 'd';
                              }
                              _refreshState();
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
              } else if (index == nTiles - 1) {
                // final tile contains the loading spinner
                if (_selectedMarketFetcher!.finished || (_selectedMarketFetcher!.loadedResults.length == 0)) {
                  return Container(height: 0);
                } else {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              }
              if (_selectedMarketFetcher!.loadedResults.length == 0) {
                // no results here
                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Center(child: Text("Sorry, no results :'(")),
                );
              } else {
                return MarketTile(
                  market: _selectedMarketFetcher!.loadedResults[index - 1],
                  returnsPeriod: returnsPeriod,
                  league: widget.league,
                );
              }
            },
            separatorBuilder: (context, index) => Divider(
              thickness: 2,
              height: 2,
            ),
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
