import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/portfolio/donut.dart';
import 'package:sportfolios_alpha/screens/portfolio/price_chart.dart';
import 'package:sportfolios_alpha/utils/axis_range.dart';

class Portfolio extends StatefulWidget {

  // Portfolio({Portfolio portfoio})
  Portfolio({Key key}) : super(key: key);

  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: Text(
            'Portfolio',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 22,
                letterSpacing: 0.8),
          )),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[200], Colors.white])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            Center(child: AnimatedDonutChart()),
            SizedBox(height: 15),
            Divider(thickness: 1),
            SizedBox(height: 15),
            TabbedPriceGraph(
              price1h: randomGraph(25),
              price1d: randomGraph(25),
              price1w: randomGraph(25),
              price1M: randomGraph(25),
              priceMax: randomGraph(25),
            )
          ],
        ),
      ),
    );
  }
}
