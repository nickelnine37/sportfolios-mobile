import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      children: [
        AnimatedDonutChart(widget.portfolio),
        SizedBox(height: 20),
        Consumer(builder: (context, watch, child) {
          String asset = watch(selectedAssetProvider).asset;
          asset = asset == null ? '' : asset;
          return Text(asset);
        })
      ],
    );
  }
}
