import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';
import 'package:sportfolios_alpha/plots/donut_chart.dart';

class Composition extends StatefulWidget {
  final Portfolio portfolio;
  Composition(this.portfolio);

  @override
  _CompositionState createState() => _CompositionState();
}

class _CompositionState extends State<Composition> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [AnimatedDonutChart(widget.portfolio)],
        );
  }
}