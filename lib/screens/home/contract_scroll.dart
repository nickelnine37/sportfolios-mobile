import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:provider/provider.dart';
import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/data_models/leagues.dart';
import 'package:sportfolios_alpha/fetch/fetch_contracts.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/screens/home/contract_details.dart';
import 'package:sportfolios_alpha/utils/number_format.dart';

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
  Future<void> _contractsFuture;
  TextEditingController _textController = TextEditingController();

  DefaultContractFetcher _defaultContractFetcher;
  SearchQueryContractFetcher _searchQueryContractFetcher;
  ContractFetcher _selectedContractFetcher;

  ScrollController _scrollController = ScrollController(initialScrollOffset: 50);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  bool _justSwitchedLeagues() {
    return _defaultContractFetcher != null && _defaultContractFetcher.leagueID != widget.league.leagueID;
  }

  bool _scrolledToBottom() {
    return _scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange;
  }

  void _scrollListener() async {
    if (!_selectedContractFetcher.finished) {
      if (_scrolledToBottom()) {
        await Future.delayed(Duration(seconds: 1), () => 12);
        // don't reassign the future here - it's just for the initial building
        await _selectedContractFetcher.get10();
        setState(() {});
      }
    }
  }

  void _refreshState() {
    _defaultContractFetcher = DefaultContractFetcher(widget.league.leagueID, widget.contractType);
    _selectedContractFetcher = _defaultContractFetcher;
    _contractsFuture = _selectedContractFetcher.get10();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // this runs when we first load the widget. Kind of like ititState but
    // we ensure nothing is null
    if (_selectedContractFetcher == null) {
      _refreshState();
    }
    // this runs when we switch leagues
    else if (_justSwitchedLeagues()) {
      _refreshState();
      _searchQueryContractFetcher = null;
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
                      _selectedContractFetcher = _searchQueryContractFetcher;
                      await _selectedContractFetcher.get10();
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      // contentPadding: EdgeInsets.only(bottom: 23),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: 'Search',
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
                  return Container(
                    width: double.infinity,
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  );
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

class ContractTile extends StatefulWidget {
  final Contract contract;
  final double height;
  final double imageHeight;
  final EdgeInsets padding;

  ContractTile({
    this.contract,
    this.height = 115.0,
    this.imageHeight = 50.0,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
  });

  @override
  State<StatefulWidget> createState() {
    return ContractTileState();
  }
}

class ContractTileState extends State<ContractTile> {
  final double upperTextSize = 16.0;
  final double lowerTextSize = 12.0;
  final double spacing = 3.0;

  ContractTileState();

  void _goToContractDetailsPage() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return ContractDetails(widget.contract);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _goToContractDetailsPage,
      child: Container(
        height: widget.height,
        padding: widget.padding,
        child: Row(children: [
          widget.contract.imageURL != null
              ? Container(
                  height: widget.imageHeight,
                  width: widget.imageHeight,
                  child: CachedNetworkImage(
                    imageUrl: widget.contract.imageURL,
                    height: widget.imageHeight,
                  ))
              : Container(height: widget.imageHeight),
          Expanded(
              child: Container(
            padding: EdgeInsets.only(left: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.contract.name, style: TextStyle(fontSize: upperTextSize)),
                    SizedBox(height: spacing),
                    Text(
                      '${widget.contract.info1} • ${widget.contract.info2} • ${widget.contract.info3}',
                      style: TextStyle(fontSize: lowerTextSize, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Consumer(
                  builder: (context, watch, value) {
                    String currency = watch(settingsProvider).currency;
                    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(formatCurrency(widget.contract.price, currency)),
                      SizedBox(height: spacing),
                      Text(
                          '${widget.contract.dayValueChange > 0 ? '+' : '-'}${formatCurrency(widget.contract.dayValueChange.abs(), currency)}  (${widget.contract.dayValueChange > 0 ? '+' : '-'}${formatCurrency(widget.contract.dayValueChange.abs(), currency)})',
                          style: TextStyle(
                              fontSize: lowerTextSize,
                              color:
                                  widget.contract.dayValueChange > 0 ? Colors.green[300] : Colors.red[300])),
                    ]);
                  },
                )
              ]),
              Expanded(
                child: Container(
                    padding: EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
                    width: double.infinity,
                    child: CustomPaint(painter: MiniPriceChartPainter(widget.contract.pD))),
              )
            ]),
          ))
        ]),
      ),
    );
  }
}

class MiniPriceChartPainter extends CustomPainter {
  List<double> pathY;
  Color lineColor;
  MiniPriceChartPainter(this.pathY) {
    if (this.pathY[0] > this.pathY[this.pathY.length - 1])
      this.lineColor = Colors.red[300];
    else
      this.lineColor = Colors.green[300];
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    pathY.reduce((value, element) => null);

    int N = pathY.length;
    double pmin = pathY.reduce(min);
    double pmax = pathY.reduce(max);
    List pathpY = pathY.map((y) => size.height * (1 - (y - pmin) / (pmax - pmin))).toList();
    List pathpX = List.generate(N, (index) => index * size.width / (N - 1));

    Path path = Path();
    path.moveTo(pathpX[0], pathpY[0]);
    for (int i = 0; i < N; i++) {
      if (i % 5 == 0) {
        path.lineTo(pathpX[i], pathpY[i]);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
