import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/firebase/portfolios.dart';
import '../../providers/authenication_provider.dart';
import '../../data/objects/portfolios.dart';
import '../leaderboard/pie_chart.dart';
import 'holdings.dart';
import 'performance.dart';
import '../../utils/strings/number_format.dart';

class PortfolioPage extends StatefulWidget {
  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  Future<void>? portfoliosFuture;
  late int nPortfolios;
  List<Portfolio> loadedPortfolios = [];
  List<String?> alreadyLoadedPortfolioIds = [];
  Portfolio? currentPortoflio;

  @override
  void initState() {
    super.initState();
    portfoliosFuture = _getPortfolios();
    print('initialising portfolio state');
  }

  Future<void> _getPortfolios() async {
    DocumentSnapshot result =
        await FirebaseFirestore.instance.collection('users').doc(AuthService().currentUid).get();


    for (String portfolioId in result['portfolios']) {
      if (!alreadyLoadedPortfolioIds.contains(portfolioId)) {
        Portfolio portfolio = await getPortfolioById(portfolioId);
        await portfolio.populateMarketsFirebase();
        await portfolio.populateMarketsServer();
        portfolio.getCurrentValue();
        // await portfolio.updateMarketsHistoricalX();
        // await portfolio.computeHistoricalValue();
        portfolio.getHistoricalValue();
        loadedPortfolios.add(portfolio);
        alreadyLoadedPortfolioIds.add(portfolio.id);
      }
    }

    nPortfolios = loadedPortfolios.length;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // this may be null if selectedPortfolio is not set yet
    currentPortoflio = getLoadedPortfolioById(prefs.getString('selectedPortfolio'));
    if (currentPortoflio == null && nPortfolios > 0) {
      currentPortoflio = loadedPortfolios[0];
    }
  }

  Portfolio? getLoadedPortfolioById(String? id) {
    // if (loadedPortfolios != null) {
    return loadedPortfolios.firstWhere((Portfolio portf) => portf.id == id,
        orElse: () => loadedPortfolios[0]);
    // }
    // return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: portfoliosFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (loadedPortfolios.length == 0) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add a new portfolio to get started',
                      style: TextStyle(fontSize: 18, color: Colors.grey[800])),
                  SizedBox(height: 25),
                  TextButton(
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(Size(150, 40)),
                        overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ))),
                    child: Text('New portfolio   +', style: TextStyle(color: Colors.white, fontSize: 16)),
                    onPressed: () async {
                      bool? output = await showDialog(
                        context: context,
                        builder: (context) {
                          return NewPortfolioDialogue();
                        },
                      );
                      if (output ?? false) {
                        setState(() {
                          portfoliosFuture = _getPortfolios();
                        });
                      }
                    },
                  )
                ],
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              toolbarHeight: 100,
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
                            return PortfolioSelectorDialogue(loadedPortfolios);
                          },
                        );

                        if (newlySelectedPortfolioId != null) {
                          setState(() {
                            currentPortoflio = getLoadedPortfolioById(newlySelectedPortfolioId);
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
                                currentPortoflio,
                                strokeWidth: 8,
                              )),
                          SizedBox(width: 15),
                          Text(currentPortoflio!.name!,
                              style: TextStyle(fontSize: 25.0, color: Colors.white)),
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
                    onPressed: () async {
                      bool? output = await showDialog(
                        context: context,
                        builder: (context) {
                          return PortfolioSettingsDialogue(currentPortoflio);
                        },
                      );
                      if (output ?? false) {
                        setState(() {});
                      }
                    }),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white, size: 25),
                  onPressed: () async {
                    bool? output = await showDialog(
                      context: context,
                      builder: (context) {
                        return NewPortfolioDialogue();
                      },
                    );
                    if (output ?? false) {
                      setState(() {
                        portfoliosFuture = _getPortfolios();
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
              children: [Holdings(currentPortoflio), Performance(currentPortoflio)],
            ),
          ),
        );
      },
    );
  }

}

class PortfolioSelectorDialogue extends StatelessWidget {
  final List<Portfolio> portfolios;

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
                child: Text('Select a Portfolio',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Container(
              height: 245,
              child: ListView.separated(
                itemCount: portfolios.length,
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: Container(
                        height: 30,
                        width: 30,
                        child: MiniDonutChart(
                          portfolios[i],
                          strokeWidth: 8,
                        )),
                    trailing: Text(formatCurrency(portfolios[i].currentValue, 'GBP')),
                    title: Text(portfolios[i].name!),
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('selectedPortfolio', portfolios[i].id);
                      Navigator.of(context).pop(portfolios[i].id);
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

class NewPortfolioDialogue extends StatefulWidget {
  @override
  _NewPortfolioDialogueState createState() => _NewPortfolioDialogueState();
}

class _NewPortfolioDialogueState extends State<NewPortfolioDialogue> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool public = true;
  String? name;
  bool loading = false;

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
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (!FocusScope.of(context).hasPrimaryFocus) {
                      FocusManager.instance.primaryFocus!.unfocus();
                    }

                    setState(() {
                      loading = true;
                    });

                    await Future.delayed(Duration(seconds: 1));
                    await addNewPortfolio(name, public);

                    // pop true to indicate portfolio has been added
                    Navigator.of(context).pop(true);
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
                child:
                    Text('Portfolio Setings', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
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
            Text(
              'Public portfolios will be entered into the leaderboard and will be viewable by other users.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    )),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    if (!FocusScope.of(context).hasPrimaryFocus) {
                      FocusManager.instance.primaryFocus!.unfocus();
                    }

                    if ((output['name'] == init_values['name']) &&
                        (output['public'] == init_values['public'])) {
                      print('Nothing Changed');
                      // pop bool indicating whether changes were made
                      Navigator.of(context).pop(false);
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
                      Navigator.of(context).pop(true);
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
