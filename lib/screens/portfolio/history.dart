import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';


class History extends StatefulWidget {
  final Portfolio portfolio;
  History(this.portfolio);
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('key'),
    );
  }
}
