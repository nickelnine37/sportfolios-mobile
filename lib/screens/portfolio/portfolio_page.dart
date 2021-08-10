import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/plots/mini_donut_chart.dart';
import 'package:sportfolios_alpha/screens/home/options/buy_contract.dart';
import 'package:sportfolios_alpha/screens/portfolio/comments.dart';

import '../../data/firebase/portfolios.dart';
import '../../utils/authentication/authenication_provider.dart';
import '../../data/objects/portfolios.dart';
import 'dialogues/new_portfolio.dart';
import 'dialogues/portfolio_settings.dart';
import 'holdings.dart';
import 'performance.dart';
import '../../utils/strings/number_format.dart';

class PortfolioPage extends StatefulWidget {
  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  Future<void>? portfoliosFuture;
  Map<String, Portfolio> portfolios = {};
  String? selectedPortfolioId;
  SharedPreferences? prefs;

  List<int> registeredTransactions = [];

  @override
  void initState() {
    super.initState();
    portfoliosFuture = _getFreshPortfolios();
  }

  // run once only in initState - gets all portfolios fresh
  Future<void> _getFreshPortfolios() async {
    prefs = await SharedPreferences.getInstance();
    String uid = AuthService().currentUid;
    fire.DocumentSnapshot result = await fire.FirebaseFirestore.instance.collection('users').doc(uid).get();

    for (String portfolioId in result['portfolios']) {
      print(portfolioId);
      Portfolio? portfolio = await _getFreshPortfolio(portfolioId);
      if (portfolio != null) {
        portfolios[portfolioId] = portfolio;
      }
    }
  }

  Future<Portfolio?> _getFreshPortfolio(String portfolioId) async {
    Portfolio? portfolio = await getPortfolioById(portfolioId);
    if (portfolio == null) {
      return null;
    } else {
      await portfolio.populateMarketsFirebase();
      await portfolio.populateMarketsServer();
      portfolio.getCurrentValue();
      portfolio.getHistoricalValue();
      return portfolio;
    }
  }

  Future<void> _addNewPortfolio(String portfolioId) async {
    Portfolio? newPortfolio = await _getFreshPortfolio(portfolioId);
    if (newPortfolio != null) {
      portfolios[portfolioId] = newPortfolio;
      selectedPortfolioId = portfolioId;
    }
  }

  // Future<void> _refreshPortfolio(String portfolioId) async {
  //   if (await portfolios[portfolioId]!.checkForUpdates()) {
  //     portfolios[portfolioId] = (await _getFreshPortfolio(portfolioId))!;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context, ScopedReader watch, Widget? child) {
      final portfoliloWatcher = watch(purchaseCompleteProvider);

      String? pid = portfoliloWatcher.portfolio;
      int? transactionId = portfoliloWatcher.transactionId;
      Transaction? transaction = portfoliloWatcher.transaction;

      if (transactionId != null) {
        if (!registeredTransactions.contains(transactionId)) {
          registeredTransactions.add(transactionId);
          portfolios[pid!]!.addTransaction(transaction!);
        }
      }

      return FutureBuilder(
        future: portfoliosFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // create first portfolio page
          if (portfolios.length == 0) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Add a new portfolio to get started', style: TextStyle(fontSize: 18, color: Colors.grey[800])),
                    SizedBox(height: 25),
                    TextButton(
                      style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all<Size>(Size(150, 40)),
                          overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                          shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ))),
                      child: Text('New portfolio   +', style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: () async {
                        String? newPid = await showDialog(
                          context: context,
                          builder: (context) {
                            return NewPortfolioDialogue();
                          },
                        );
                        if (newPid != null) {
                          setState(() {
                            portfoliosFuture = _addNewPortfolio(newPid);
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
            );
          }

          if (selectedPortfolioId == null && portfolios.length > 0) {
            selectedPortfolioId = prefs!.getString('selectedPortfolio');
            if (selectedPortfolioId == null) {
              selectedPortfolioId = portfolios.keys.toList()[0];
            }
          }

          return DefaultTabController(
            length: portfolios[selectedPortfolioId]!.public ? 3 : 2,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                toolbarHeight: 110,
                title: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () async {
                            String? newlySelectedPortfolioId = await showDialog(
                              context: context,
                              builder: (context) {
                                return PortfolioSelectorDialogue(portfolios);
                              },
                            );

                            if (newlySelectedPortfolioId != null) {
                              setState(() {
                                selectedPortfolioId = newlySelectedPortfolioId;
                              });
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 10),
                              Container(
                                  height: 25,
                                  width: 25,
                                  child: MiniDonutChart(
                                    portfolios[selectedPortfolioId]!,
                                    strokeWidth: 8,
                                  )),
                              SizedBox(width: 17),
                              Text(portfolios[selectedPortfolioId]!.name, style: TextStyle(fontSize: 25.0, color: Colors.white)),
                              Container(
                                padding: EdgeInsets.all(0),
                                width: 30,
                                height: 20,
                                child: Center(
                                  child: Icon(Icons.arrow_drop_down, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                actions: [
                  IconButton(
                      icon: Icon(Icons.settings, color: Colors.white),
                      onPressed: selectedPortfolioId == null
                          ? null
                          : () async {
                              String? output = await showDialog(
                                context: context,
                                builder: (context) {
                                  return PortfolioSettingsDialogue(portfolios[selectedPortfolioId]!);
                                },
                              );
                              if (output == 'updated') {
                                setState(() {});
                              } else if (output == 'deleted') {
                                setState(() {
                                  portfolios.remove(selectedPortfolioId);
                                  selectedPortfolioId = null;
                                });
                              }
                            }),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white, size: 25),
                    onPressed: () async {
                      String? newPid = await showDialog(
                        context: context,
                        builder: (context) {
                          return NewPortfolioDialogue();
                        },
                      );
                      if (newPid != null) {
                        setState(() {
                          portfoliosFuture = _addNewPortfolio(newPid);
                        });
                      }
                    },
                  ),
                ],
                bottom: TabBar(
                  labelPadding: EdgeInsets.all(5),
                  tabs: <Icon>[
                        Icon(Icons.donut_large, color: Colors.white, size: 21),
                        Icon(Icons.timeline, color: Colors.white, size: 24),
                      ] +
                      (portfolios[selectedPortfolioId]!.public ? <Icon>[Icon(Icons.chat_bubble, color: Colors.white, size: 20)] : <Icon>[]),
                ),
              ),
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                      Holdings(portfolio: portfolios[selectedPortfolioId], owner: true),
                      Performance(portfolios[selectedPortfolioId]),
                    ] +
                    (portfolios[selectedPortfolioId]!.public
                        ? <Widget>[PortfolioComments(portfolio: portfolios[selectedPortfolioId]!)]
                        : <Widget>[]),
              ),
            ),
          );
        },
      );
    });
  }
}

class PortfolioSelectorDialogue extends StatelessWidget {
  final Map<String, Portfolio> portfolios;

  PortfolioSelectorDialogue(this.portfolios);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 300,
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
        ),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('Select a Portfolio', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Container(
              height: 245,
              child: ListView.separated(
                itemCount: portfolios.length,
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (context, i) {
                  String pid = portfolios.keys.toList()[i];
                  return ListTile(
                    leading: Container(
                        height: 30,
                        width: 30,
                        child: MiniDonutChart(
                          portfolios[pid]!,
                          strokeWidth: 8,
                        )),
                    trailing: Text(formatCurrency(portfolios[pid]!.currentValue, 'GBP')),
                    title: Text(portfolios[pid]!.name),
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('selectedPortfolio', pid);
                      Navigator.of(context).pop(pid);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

