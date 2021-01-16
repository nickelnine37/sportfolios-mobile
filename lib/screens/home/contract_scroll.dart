import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/data_models/leagues.dart';
import 'package:sportfolios_alpha/fetch/fetch_contracts.dart';
import 'package:sportfolios_alpha/screens/home/contract_tile.dart';

/// Widget for
class ContractScroll extends StatefulWidget {
  final League league;
  final String contractType;
  ContractScroll(this.league, this.contractType);

  @override
  State<StatefulWidget> createState() {
    return ContractScrollState();
  }
}

class ContractScrollState extends State<ContractScroll> with AutomaticKeepAliveClientMixin {
  /// [_contractsFuture] helps us load a spinner at the start, when the first 10 contracts are
  /// being fetched
  Future<void> _contractsFuture;

  /// three contractFeter-type objects:
  /// 1. [_defaultContractFetcher]: this is responsible for getting contracts when casually scrolling
  /// 2. [_searchQueryContractFetcher]: this is responsible for getting contracts when a search has been entered
  /// 3. [_selectedContractFetcher]: this is a helper variable which just holds whichever of the above two we are
  /// currently considering.
  DefaultContractFetcher _defaultContractFetcher;
  SearchQueryContractFetcher _searchQueryContractFetcher;
  ContractFetcher _selectedContractFetcher;

  /// initialise scroll controller with offset to cover search bar. We also use this when
  /// checking if we've scrolled to the bottom, to load more contracts
  ScrollController _scrollController = ScrollController(initialScrollOffset: 50);

  /// This is just so we can do some basic things with the enterered text like clear it
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  /// helper function: has the user just switched leagues on us?
  bool _justSwitchedLeagues() {
    return _defaultContractFetcher != null && _defaultContractFetcher.leagueID != widget.league.leagueID;
  }

  /// helper function: has the user scrolled to the bottom of the page?
  bool _scrolledToBottom() {
    return _scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange;
  }

  /// listener for scroll controller
  void _scrollListener() async {
    if (!_selectedContractFetcher.finished) {
      if (_scrolledToBottom()) {
        // await Future.delayed(Duration(seconds: 1), () => 12);
        // don't reassign the future here - it's just for the initial building
        await _selectedContractFetcher.get10();
        setState(() {});
      }
    }
  }

  /// 'factory reset' our page. Get a new [DefaultContractFetcher] for the relevant league,
  void _refreshState() {
    _defaultContractFetcher = DefaultContractFetcher(widget.league.leagueID, widget.contractType);
    _searchQueryContractFetcher = null;
    _selectedContractFetcher = _defaultContractFetcher;
    _contractsFuture = _selectedContractFetcher.get10();
  }

  @override
  Widget build(BuildContext context) {
    // needed for mixin
    super.build(context);

    // runs when we first load the widget or we've just switched leagues
    if (_selectedContractFetcher == null || _justSwitchedLeagues()) {
      _refreshState();
    }

    return FutureBuilder(
      future: _contractsFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Center(child: Text('Error'));
        } else {
          return ListView.separated(
            controller: _scrollController,
            itemCount: _selectedContractFetcher.loadedResults.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 1),
                  height: 47,
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (String value) async {
                      _searchQueryContractFetcher = SearchQueryContractFetcher(
                        value.trim().toLowerCase(),
                        widget.league.leagueID,
                        widget.contractType,
                      );
                      await _searchQueryContractFetcher.get10();
                      _selectedContractFetcher = _searchQueryContractFetcher;
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText:
                          'Search ${widget.contractType.split('_')[0]} contracts (${widget.contractType.split('_')[1]})',
                      icon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _textController.clear();
                          _selectedContractFetcher = _defaultContractFetcher;
                          FocusScope.of(context).unfocus();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                );
              } else if (index == _selectedContractFetcher.loadedResults.length + 1) {
                if (_selectedContractFetcher.finished) {
                  return Container(height: 0);
                } else {
                  return Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator()));
                }
              }
              return ContractTile(contract: _selectedContractFetcher.loadedResults[index - 1]);
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
