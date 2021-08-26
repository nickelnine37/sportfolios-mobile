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
              padding: EdgeInsets.only(left: 20, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: double.infinity,
                      // color: Colors.blue.withOpacity(0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(portfolio.name, style: TextStyle(fontSize: upperTextSize), overflow: TextOverflow.ellipsis, maxLines: 1,),
                          SizedBox(height: spacing),
                          Text(
                            portfolio.username,
                            style: TextStyle(fontSize: lowerTextSize, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: double.infinity, 
                      // color: Colors.red.withOpacity(0.2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formatCurrency(portfolio.currentValue, 'GBP'),
                              style: TextStyle(fontSize: upperTextSize),
                            ),
                            SizedBox(height: spacing),
                            Container(
                              // color: Colors.green.withOpacity(0.2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
