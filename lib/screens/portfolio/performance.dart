import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';


class Performance extends StatefulWidget {
  final Portfolio portfolio;
  Performance(this.portfolio);
  @override
  _PerformanceState createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [TabbedPriceGraph(priceHistory: widget.portfolio.historicalValue, times: widget.portfolio.times)]);
    // return Container();
  }
}
