import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/firebase/portfolios.dart';
import 'package:sportfolios_alpha/data/models/instruments.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/plots/donut_chart.dart';
import 'package:sportfolios_alpha/plots/price_chart.dart';
import 'package:sportfolios_alpha/utils/arrays.dart';

class PortfolioPage extends StatefulWidget {
  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  Future<List<Portfolio>> portfoliosFuture;
  int selectedPortfolio = 0;
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
        if (snapshot.hasData) {
          List<Portfolio> userPortfolios = snapshot.data;

          if (nPortfolios == 0) {
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
          } else {
            return Scaffold(
              appBar: AppBar(
                // iconTheme: ,
                centerTitle: true,
                title: DropdownButton(
                  value: selectedPortfolio,
                  items: range(userPortfolios.length)
                      .map((i) => DropdownMenuItem(
                          child: Text(
                            userPortfolios[i].name,
                            style: TextStyle(fontSize: 20),
                          ),
                          value: i))
                      .toList(),
                  onChanged: (value) {
                    if (selectedPortfolio != value) {
                      setState(() {
                        selectedPortfolio = value;
                      });
                    }
                  },
                ),
                actions: [
                  IconButton(
                      icon: Icon(Icons.add),
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
                      })
                ],
                iconTheme: IconThemeData(color: Colors.white),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    child: AnimatedDonutChart(portfolio: userPortfolios[selectedPortfolio]),
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(5),
                    // child: TabbedPriceGraph(instrument: userPortfolios[selectedPortfolio]),
                  ),
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Scaffold(
            appBar: AppBar(
              title: Text('Error', style: TextStyle(color: Colors.white)),
            ),
            body: Center(child: Text("An unknown error occurred :'(")),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
                // title: Text('Loading', style: TextStyle(color: Colors.white)),
                ),
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
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
                    Navigator.of(context).pop(output);
                  }

                  // To close the dialog
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
