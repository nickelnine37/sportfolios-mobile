import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportfolios_alpha/data/api/requests.dart';
import 'package:sportfolios_alpha/plots/mini_donut_chart.dart';
import 'package:sportfolios_alpha/screens/home/options/buy_contract.dart';

import '../../data/firebase/portfolios.dart';
import '../../providers/authenication_provider.dart';
import '../../data/objects/portfolios.dart';
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

  // late int nPortfolios;
  // List<Portfolio> loadedPortfolios = [];
  // List<String?> alreadyLoadedPortfolioIds = [];
  // Portfolio? currentPortfolio;

  @override
  void initState() {
    super.initState();
    portfoliosFuture = _getFreshPortfolios();
    print('initialising portfolio state');
  }

  // run once only in initState - gets all portfolios fresh
  Future<void> _getFreshPortfolios() async {
    prefs = await SharedPreferences.getInstance();
    String uid = AuthService().currentUid;
    DocumentSnapshot result = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    for (String portfolioId in result['portfolios']) {
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

  Future<void> _refreshPortfolio(String portfolioId) async {
    if (await portfolios[portfolioId]!.checkForUpdates()) {
      portfolios[portfolioId] = (await _getFreshPortfolio(portfolioId))!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context, watch, Widget? child) {
      final portfoliloWatcher = watch(purchaseCompleteProvider);
      String? pid = portfoliloWatcher.portfolio;

      print('Pid has changed!! : ${pid}');

      if (pid != null) {
        portfoliosFuture = _refreshPortfolio(pid);
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
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                toolbarHeight: 110,
                title: Column(children: [
                  Row(
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
                            SizedBox(width: 15),
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
                ]),
                actions: [
                  IconButton(
                      icon: Icon(Icons.settings, color: Colors.white),
                      onPressed:  selectedPortfolioId == null ? null : () async {
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
                  tabs: <Row>[
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Holdings', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.donut_large, color: Colors.white, size: 17)
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Performance', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.show_chart, color: Colors.white, size: 17)
                    ]),
                  ],
                ),
              ),
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Holdings(portfolios[selectedPortfolioId]),
                  Performance(portfolios[selectedPortfolioId]),
                ],
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

// pop String new Pid if success, null otherwise
class NewPortfolioDialogue extends StatefulWidget {
  @override
  _NewPortfolioDialogueState createState() => _NewPortfolioDialogueState();
}

class _NewPortfolioDialogueState extends State<NewPortfolioDialogue> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool public = true;
  String name = '';
  bool loading = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: error ? 350 : 300,
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
                child: Text('New portfolio', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Name', style: TextStyle(fontSize: 16)),
                        Container(
                          width: 100,
                          height: 40,
                          child: TextFormField(
                            decoration: InputDecoration(hintText: 'MyPortfolio'),
                            onChanged: (String value) {
                              name = value;
                            },
                            validator: (String? value) {
                              if (value == '' || value == null) {
                                return 'Please enter valid portfolio name';
                              } else if (value.length > 20) {
                                return 'Portfolio names must be 20 characters or less';
                              } else {
                                return null;
                              }
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Public', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: public,
                          onChanged: (value) {
                            setState(() {
                              public = value;
                            });
                          },
                          activeTrackColor: Colors.lightBlueAccent,
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Public portfolios will be entered into the leaderboard and will be viewable by other users.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            error
                ? Text(
                    'There was an error creating a new portfolio. Please try again later',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  )
                : Container(),
            error ? SizedBox(height: 15) : Container(),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                  // shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                ),
                onPressed: error
                    ? () {
                        Navigator.of(context).pop(null);
                      }
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (!FocusScope.of(context).hasPrimaryFocus) {
                            FocusManager.instance.primaryFocus!.unfocus();
                          }

                          setState(() {
                            loading = true;
                          });

                          String? newPid = await createNewPortfolio(name, public);
                          // String? newPid = null;
                          // await Future.delayed(Duration(seconds: 2));

                          await Future.delayed(Duration(seconds: 1));

                          if (newPid == null) {
                            setState(() {
                              error = true;
                              loading = false;
                            });
                          } else {
                            // pop true to indicate portfolio has been added
                            Navigator.of(context).pop(newPid);
                          }
                        }
                      },
                child: loading
                    ? Container(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ))
                    : Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// pop 'updated' if the portfolio was updated
// pop null if nothing changed
// pop 'deleted' if the portfolio was deleted
class PortfolioSettingsDialogue extends StatefulWidget {
  final Portfolio? portfolio;

  PortfolioSettingsDialogue(this.portfolio);

  @override
  _PortfolioSettingsDialogueState createState() => _PortfolioSettingsDialogueState();
}

class _PortfolioSettingsDialogueState extends State<PortfolioSettingsDialogue> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Map<String, dynamic> init_values;
  late Map<String, dynamic> output;
  bool loading = false;
  bool deleting = false;

  @override
  void initState() {
    init_values = {'name': widget.portfolio!.name, 'public': widget.portfolio!.public};
    output = {'name': widget.portfolio!.name, 'public': widget.portfolio!.public};
    super.initState();
  }

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
                child: Text('Portfolio Setings', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Name', style: TextStyle(fontSize: 16)),
                        Container(
                          width: 150,
                          height: 40,
                          child: TextFormField(
                            initialValue: widget.portfolio!.name,
                            decoration: InputDecoration(hintText: 'MyPortfolio'),
                            onChanged: (String value) {
                              output['name'] = value;
                            },
                            validator: (String? value) {
                              if (value == '' || value == null) {
                                return 'Please enter valid portfolio name';
                              } else if (value.length > 20) {
                                return 'Portfolio names must be 20 characters or less';
                              } else {
                                return null;
                              }
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Public', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: output['public'],
                          onChanged: (value) {
                            setState(() {
                              output['public'] = value;
                            });
                          },
                          activeTrackColor: Colors.lightBlueAccent,
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Public portfolios will be entered into the leaderboard and will be viewable by other users.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                // alignment: Alignment.bottomRight,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      bool? delete = await showDialog(
                          context: context,
                          builder: (context) {
                            return DeletePortfolioDiaglogue(widget.portfolio!.name);
                          });

                      // if we want to delete
                      if (delete ?? false) {
                        // set the delete wheel spinning
                        setState(() {
                          deleting = true;
                        });
                        // delete the portfolio and wait some more
                        await deletePortfolio(widget.portfolio!.id);
                        await Future.delayed(Duration(seconds: 2));

                        // stop the wheel spinning
                        setState(() {
                          deleting = false;
                        });

                        // pause
                        await Future.delayed(Duration(milliseconds: 800));

                        // pop 'deleted'
                        Navigator.of(context).pop('deleted');
                      }
                    },
                    child: deleting
                        ? Container(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ))
                        : Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all<Color>(Colors.red[400]!),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red[400]!),
                      // shape: MaterialStateProperty.all<OutlinedBorder>(
                      //   RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      // ),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                      // shape: MaterialStateProperty.all<OutlinedBorder>(
                      //   RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      // ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        if (!FocusScope.of(context).hasPrimaryFocus) {
                          FocusManager.instance.primaryFocus!.unfocus();
                        }

                        if ((output['name'] == init_values['name']) && (output['public'] == init_values['public'])) {
                          print('Nothing Changed');
                          // pop bool indicating whether changes were made
                          Navigator.of(context).pop(null);
                        } else {
                          print('Something Changed');
                          setState(() {
                            loading = true;
                          });
                          await Future.delayed(Duration(seconds: 1));
                          await FirebaseFirestore.instance
                              .collection('portfolios')
                              .doc(widget.portfolio!.id)
                              .update(output)
                              .then((value) => print("User Updated"))
                              .catchError((error) => print("Failed to update user portfolio: $error"));

                          widget.portfolio!.name = output['name'];
                          widget.portfolio!.public = output['public'];
                          // pop bool indicating whether changes were made
                          Navigator.of(context).pop('updated');
                        }
                      }
                    },
                    child: loading
                        ? Container(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ))
                        : Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// pop true to delete the portfolio
// pop false or null to keep it
class DeletePortfolioDiaglogue extends StatelessWidget {
  final String portfolioName;

  DeletePortfolioDiaglogue(this.portfolioName);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 200,
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
                padding: EdgeInsets.all(16),
                child: Text('Delete Portfolio', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Are you sure you want to delete the portfolio ${portfolioName}? This is irreversible',
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 20)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
