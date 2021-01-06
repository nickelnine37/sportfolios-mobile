import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/portfolio/donut.dart';
import 'package:sportfolios_alpha/screens/portfolio/price_chart.dart';

class Portfolio extends StatefulWidget {
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 22, letterSpacing: 0.8),
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
            SizedBox(height: 15),
            //   DonutGraph(
            //   percentComplete: 1,
            //   amounts: {'BTC': 0.034, 'ETH': 0.056},
            //   prices: {'BTC': 29000, 'ETH': 12000},
            //   colors: {'BTC': Colors.green, 'ETH': Colors.red},
            // ),
            Center(child: AnimatedBarChart()),
            SizedBox(height: 15),
            tabSection(context)
          ],
        ),
      ),
    );
  }
}
