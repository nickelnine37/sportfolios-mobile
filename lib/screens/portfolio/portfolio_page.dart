import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/firebase/portfolios.dart';
import 'package:sportfolios_alpha/data/objects/markets.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/plots/donut_chart.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';

class PortfolioPage extends StatefulWidget {
  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  Future<List<Portfolio>> portfoliosFuture;
  int _selectedPortfolio = 0;
  int nPortfolios;

  @override
  void initState() {
    super.initState();
    portfoliosFuture = _getPortfolios();
  }

  /// To be called when the portfolio page is initialised. This will load
  /// the user's portfolios from firebase. It returns a list of [Portfolio]s
  Future<List<Portfolio>> _getPortfolios() async {
    // load the entry in the users collection for the current user
    // this is where a list of their portfolios is located
    DocumentSnapshot result =
        await FirebaseFirestore.instance.collection('users').doc(AuthService().currentUid).get();

    // this is what we want to return: it contains a list of <Portfoilio> objects
    List<Portfolio> userPortfolios = [];

    // iterate through the array containing the list of documentIDs for their portfolios
    for (String portfolioId in result['portfolios']) {
      Portfolio portfolio = await getDeepPortfolioById(portfolioId);
      userPortfolios.add(portfolio);
    }

    nPortfolios = userPortfolios.length;
    return userPortfolios;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: portfoliosFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        List<Portfolio> portfolios = snapshot.data;

        if (portfolios.length == 0) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add a new portfolio to get started',
                      style: TextStyle(fontSize: 18, color: Colors.grey[800])),
                  SizedBox(height: 25),
                  FlatButton(
                    minWidth: 150,
                    height: 40,
                    color: Colors.blue[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    child: Text('New portfolio   +', style: TextStyle(color: Colors.white, fontSize: 16)),
                    onPressed: () async {
                      Map<String, dynamic> output = await showDialog(
                        context: context,
                        builder: (context) {
                          return NewPortfolioDialogue();
                        },
                      );
                      if (output != null) {
                        await addNewPortfolio(output['name'], output['public']);
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
                        int newlySelectedPortfolio = await showDialog(
                          context: context,
                          builder: (context) {
                            return PortfolioSelectorDialogue(snapshot.data);
                          },
                        );

                        setState(() {
                          _selectedPortfolio = newlySelectedPortfolio;
                        });
                        // if (newlySelectedLeague != null && newlySelectedLeague != selectedLeagueId) {
                        //   prefs.setInt('selectedLeague', newlySelectedLeague);
                        //   setState(() {
                        //     selectedLeagueId = newlySelectedLeague;
                        //   });
                        // }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 20),
                          Text(portfolios[_selectedPortfolio].name,
                              style: TextStyle(fontSize: 28.0, color: Colors.white)),
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
                      Map<String, dynamic> output = await showDialog(
                        context: context,
                        builder: (context) {
                          return PortfolioSettingsDialogue(portfolios[_selectedPortfolio]);
                        },
                      );
                      setState(() {});
                    }),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white, size: 25),
                  onPressed: () async {
                    Map<String, dynamic> output = await showDialog(
                      context: context,
                      builder: (context) {
                        return NewPortfolioDialogue();
                      },
                    );
                    if (output != null) {
                      await addNewPortfolio(output['name'], output['public']);
                      setState(() {
                        _selectedPortfolio = nPortfolios;
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
                    Text('Composition', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.donut_large, color: Colors.white, size: 17)
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('History', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.show_chart, color: Colors.white, size: 17)
                  ]),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Composition(portfolios[_selectedPortfolio]),
                History(portfolios[_selectedPortfolio])
              ],
            ),
          ),
        );
      },
    );
  }
}

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
        // children: [AnimatedDonutChart(portfolio: widget.portfolio)],
        );
  }
}

class History extends StatefulWidget {
  final Portfolio portfolio;
  History(this.portfolio);
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('key'),
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
                    title: Text(portfolios[i].name),
                    onTap: () {
                      Navigator.of(context).pop(i);
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

  Map<String, dynamic> output = {'name': null, 'public': true};

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
                              output['name'] = value;
                            },
                            validator: (String value) {
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
              child: FlatButton(
                color: Colors.blue,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    if (!FocusScope.of(context).hasPrimaryFocus) {
                      FocusManager.instance.primaryFocus.unfocus();
                    }
                    Navigator.of(context).pop();
                  }
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text(
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
  final Portfolio portfolio;

  PortfolioSettingsDialogue(this.portfolio);

  @override
  _PortfolioSettingsDialogueState createState() => _PortfolioSettingsDialogueState();
}

class _PortfolioSettingsDialogueState extends State<PortfolioSettingsDialogue> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic> init_values;
  Map<String, dynamic> output;

  @override
  void initState() {
    init_values = {'name': widget.portfolio.name, 'public': widget.portfolio.public};
    output = {'name': widget.portfolio.name, 'public': widget.portfolio.public};
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
                            initialValue: widget.portfolio.name,
                            decoration: InputDecoration(hintText: 'MyPortfolio'),
                            onChanged: (String value) {
                              output['name'] = value;
                            },
                            validator: (String value) {
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
              child: FlatButton(
                color: Colors.blue,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();

                    if (!FocusScope.of(context).hasPrimaryFocus) {
                      FocusManager.instance.primaryFocus.unfocus();
                    }

                    if ((output['name'] == init_values['name']) &&
                        (output['public'] == init_values['public'])) {
                      print('Nothing Changed');
                    } else {
                      print('Something Changed');
                    }

                    Navigator.of(context).pop(output);
                  }
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Text(
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
