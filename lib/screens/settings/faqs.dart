import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';

class FAQs extends StatefulWidget {
  FAQs({Key? key}) : super(key: key);

  @override
  _FAQsState createState() => _FAQsState();
}

class _FAQsState extends State<FAQs> {
  List<bool> isExpanded = [false, false, false, false, false, false];
  List<Text> questions = [
    Text(
      'What is a contract?',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'What is a team contract?',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'What is a player contract?',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'How do we calculate prices?',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'Delete profile.',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'Contact us.',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    )
  ];
  List<Text> answers = [
    Text(
      'A contract is an agreement entered willingly by two parties whereby one party (the user) will receive payment from the other party (Sportfolios Ltd), provided the conditions stipulated in the contract are satisfied.',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'A team contract (Long, Short, Binary, or Custom) is a contract whereby the user will receive payment at expiration (end of the season), provided the team\'s final position satisifies at least one of conditions in the contract.',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'A player contract (Long or Short) is a contract whose final value and payout depends upon the final finishing position of the player based on points accumulated throughout the season amongst all other available players.',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'Prices are calculated using Logarithmic Market Scoring Rule (LMSR). This scoring rule is used by numerous entities such as Augur, The Good Judgement Project, Inkling Markets, Cultivate Labs, and many others. The price calculated depends upon the quantity requested and the quantity already purchased by the community and as such the price will not be same as the sum of individual purchases. The user may be interest to learn more at https://www.cultivatelabs.com/prediction-markets-guide/how-does-logarithmic-market-scoring-rule-lmsr-work.',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'If the user wishes to delete their profile, one need only uninstall the application and email Sportfolios at admin@sportfolios.co.uk with your username and email address with which you registered an account.',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    Text(
      'The Sportfolios administration team can be contacted at: \n\n email: admin@sportfolios.co.uk \n mobile: 0800 555 5555',
      style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'FAQs',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool itemIsExpanded) {
              setState(() {
                isExpanded[index] = !itemIsExpanded;
              });
            },
            children: range(6)
                .map<ExpansionPanel>(
                  (int i) => ExpansionPanel(
                    isExpanded: isExpanded[i],
                    headerBuilder: (context, expanded) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: questions[i],
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: answers[i],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
