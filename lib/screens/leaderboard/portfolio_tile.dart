import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/leaderboard/leaderboard.dart';
import '../../data/objects/portfolios.dart';
import '../../plots/mini_donut_chart.dart';
import 'view_portfolio.dart';
import '../../utils/strings/number_format.dart';

class PortfolioTile extends StatelessWidget {
  final Portfolio portfolio;
  final String returnsPeriod;
  final int index;

  final double height = 100.0;
  final double imageHeight = 50.0;
  final EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 10);

  final double upperTextSize = 17.0;
  final double lowerTextSize = 15.0;
  final double spacing = 5.0;

  PortfolioTile({required this.portfolio, required this.returnsPeriod, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
          return ViewPortfolio(portfolio: portfolio);
        }));
      },
      child: Container(
        height: height,
        padding: padding,
        child: Row(children: [
          SizedBox(width: 10),
          Text('${index + 1}'),
          SizedBox(width: 25),
          Container(
            height: 40,
            width: 40,
            child: MiniDonutChart(portfolio, strokeWidth: 9),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Container(
              height: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 20, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(portfolio.name, style: TextStyle(fontSize: upperTextSize)),
                          SizedBox(height: spacing),
                          Text(
                            portfolio.username,
                            style: TextStyle(fontSize: lowerTextSize, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(portfolio.currentValue, 'GBP'),
                            style: TextStyle(fontSize: upperTextSize),
                          ),
                          SizedBox(height: spacing),
                          Row(
                            children: [
                              Text({'d': 'Last 24h: ', 'w': 'This week: ', 'm': 'This month: ', 'M': 'All time: '}[returnsPeriod]!,
                                  style: TextStyle(fontSize: lowerTextSize, color: Colors.grey[600])),
                              SizedBox(width: 5),
                              Text(
                                  '${portfolio.periodReturns[returnsPeriod]! < 0 ? '-' : '+'}${formatPercentage(portfolio.periodReturns[returnsPeriod]!.abs(), 'GBP')}',
                                  style: TextStyle(
                                      fontSize: lowerTextSize,
                                      color: portfolio.periodReturns[returnsPeriod]! >= 0 ? Colors.green[300] : Colors.red[300])),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
