import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data_models/contracts.dart';
import 'package:sportfolios_alpha/data_models/portfolios.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/screens/portfolio/donut.dart';
import 'package:sportfolios_alpha/screens/portfolio/price_chart.dart';
import 'package:sportfolios_alpha/utils/axis_range.dart';

class PortfolioPage extends StatefulWidget {
  final Portfolio portfolio;

  PortfolioPage({@required this.portfolio});

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
    DocumentSnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService().user.uid)
        .get();

    // this is what we want to return: it contains a list of <Portfoilio> objects
    List<Portfolio> userPortfolios = [];

    // iterate through the array containing the list of documentIDs for their portfolios
    for (String id in result['portfolios']) {

      List<Contract> contracts = [];
      List<int> amounts = [];

      // for each portfolioID, go and get the asociated portfolio from the  portfolios collection
      DocumentSnapshot portfolioSnapshot = await FirebaseFirestore.instance
          .collection('portfolios')
          .doc(id)
          .get();

      // each portfolio has an entry called 'contracts' which contains a map. 
      // The keys of this map are the contract IDs, and the values are the amount 
      // of that contract in the portfolio. 
      for (String contractName in portfolioSnapshot['contracts'].keys) {

        // go through each contract name, and search for this contract in the 
        // 'contracts' collection. 
        DocumentSnapshot contractSnapshot = await FirebaseFirestore.instance
            .collection('contracts')
            .doc(contractName)
            .get();

        // turn this item fetched from the database into a [Contract] object
        Contract thisContract;
        if (contractSnapshot['type'].contains('team')) 
          thisContract = TeamContract.fromMap(contractSnapshot.data());
        else 
          thisContract = PlayerContract.fromMap(contractSnapshot.data());

        // add the contract and the amount held of that contract to a list
        contracts.add(thisContract);
        amounts.add(portfolioSnapshot['contracts'][contractName]);
      }
    
    // Create a [Portfolio] object ad add it to the userPortfolios list
      userPortfolios.add(Portfolio(
        name: portfolioSnapshot['name'],
        contracts: contracts,
        amounts: amounts,
        public: portfolioSnapshot['public'],
      ));

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

          return Scaffold(
            appBar: AppBar(
              // iconTheme: ,
              elevation: 0,
              title: Row(
                children: [
                  Text(
                    userPortfolios[selectedPortfolio].name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 22,
                        letterSpacing: 0.8),
                  ),
                  SizedBox(width: 1),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    onPressed: () {},
                  ),
                ],
              ),
              actions: [IconButton(icon: Icon(Icons.add), onPressed: () {})],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                    margin: EdgeInsets.all(5),
                    color: Colors.grey[50],
                    child: Center(
                        child: AnimatedDonutChart(
                            portfolio: userPortfolios[selectedPortfolio]))),
                SizedBox(height: 15),
                Card(
                  child: TabbedPriceGraph(
                      portfolio: userPortfolios[selectedPortfolio]),
                )
              ],
            ),
          );
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
