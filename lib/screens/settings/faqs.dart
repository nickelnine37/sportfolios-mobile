import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/home/options/info_box.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQs extends StatefulWidget {
  FAQs({Key? key}) : super(key: key);

  @override
  _FAQsState createState() => _FAQsState();
}

class _FAQsState extends State<FAQs> {
  List<bool> isExpanded = [false, false, false, false, false, false];

  Widget _generateTitle(String titleText) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        titleText,
        style: TextStyle(
          color: Colors.grey[700],
          height: 1.5,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _generateBody(TextSpan bodyText) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 15),
      child: RichText(
        text: TextSpan(
          children: [bodyText],
          style: TextStyle(
            color: Colors.grey[700],
            height: 1.5,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> questions = [
      'What is a contract?',
      'What is a team contract?',
      'What is a player contract?',
      'How do we calculate prices?',
      'How can I delete my profile?',
      'Get in touch!',
    ];

    List<TextSpan> answers = [
      TextSpan(
          text:
              'Contracts are the basic building block of every market in Sportfolios. Fundamentally a contract is just an agreement that we, Sportfolios, will credit your account with some amount of money based on the outcome of a future event. For example, you could own a contract that will pay out £10.00 if Chelsea finish in the top four of the Premier League. \n\n Let\'s say you believe there is a 75% chance Chelsea finish in the top four. Then, roughly speaking, the value of that contract to you is 0.25 x £0 + 0.75 x £10 = £7.50. If the current market price is less than £7.50, you should buy it! \n\n Each basic contract has a payout of £0-£10, but you can buy more than one unit (in fact, you don\'t even need to buy a whole number of contracts). In the above example, buying 5.00 units of the same Chelsea contract would result in a payout of £50 if they finish in the top four. \n\n For each player or team there may be multiple different contracts you can buy. It\'s our job as the market maker to quote you a price for any valid contract you would like to buy. Once you own a contact, you can sell it back onto the free market at any time. '),
      TextSpan(children: [
        TextSpan(
            text:
                'In Sportfolios team contracts are all about where a team finishes in their respective domestic league, so the value of a contract is determined entirely by their expected final position in the league table. In Sportfolios, team contracts can be split into four basic categories: '),
        TextSpan(text: 'Long, Short, Binary', style: TextStyle(fontStyle: FontStyle.italic)),
        TextSpan(text: ' and '),
        TextSpan(text: 'Custom', style: TextStyle(fontStyle: FontStyle.italic)),
        TextSpan(text: '\n\nLong contract\n\n', style: TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(
            text:
                'A long contract pays out more and more the higher a team finshes in the league. It starts at some very low payout for coming last, then rises exponentially to a payout of £10 for first place. Simply put, the long contract is a good one to buy if you believe a team\'s potential has been underestimated. '),
        TextSpan(text: '\n\nShort Contract\n\n', style: TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(
            text:
                'The short contract is effectively a reversed long contract. That is, the maximum payout of £10 is given to the team which finishes last. The payout then falls off exponentially all the way to first position, for which the payout is very low. This makes the short contract worth buying if you believe a team will finish lower than most people expect. '),
        TextSpan(text: '\n\nBinary Contract\n\n', style: TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(
            text:
                'A binary contract pays out either £10 or £0 based on whether a team finishes above or below a certain position. For example, a binary contract could pay out £10 of the team finishes in the top 4, or pay out £10 if the team finishes in the bottom half. It\'s up to you to decide where the cut off is and whether the contract pays out for finishing above or below that point. Sportfolios can provide a fair market price for any binary contract you construct. '),
        TextSpan(text: '\n\nCustom Contract\n\n', style: TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(
            text:
                'A custom contract gives you absolute flexibility. You can design any basic contract you like, with any payout for any finishing position.  Sportfolios will offer you the fair market price for that contract. ')
      ]),
      TextSpan(text: ''),
      TextSpan(
          text:
              'Fundamentally all prices are driven by the forces of supply and demand. Let\'s say lots of people decide to buy long contracts for Harry Kane. We, the market makers, will respond to these new orders by pushing the price of the long contract up and pushing the price of the short contract down. In theory this should stop when the market equilibrium is reached. \n\n To be a little more specific, all of our markets operate using the Logarithmic Market Scoring Rule (LMSR). This technique is relatively standard in the world of prediction markets and has been thoroughly tested and explored in academic literature. The LMSR and similar variants have is used by numerous well-established companies such as Augur, The Good Judgement Project, Inkling Markets, Cultivate Labs, and many more. \n\n So how does the LMSR work? Wel, it can get a little technical. The curious user can find many great blog posts and resources online, for example ',
          children: [
            TextSpan(
              text: 'here',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  String _url = 'https://www.cultivatelabs.com/prediction-markets-guide/how-does-logarithmic-market-scoring-rule-lmsr-work';
                  void _launchURL() async => await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
                  _launchURL();
                },
            )
          ]),
      TextSpan(
          text:
              'If at any time you decide you no longer want to take part in Sportfolios just drop us an email at admin@sportfolios.co.uk with your username and email address. We\'ll be sure to delete your account and all the associated infomation. '),
      TextSpan(text: 'For any questions, feedack or just for a chin-wag get in touch with Ed and Cole at ', children: [
        TextSpan(
          text: 'admin@sportfolios.co.uk',
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              String _url = 'mailto:admin@sportfolios.co.uk';
              void _launchURL() async => await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
              _launchURL();
            },
        )
      ])
    ];

    Widget playerContract = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 15),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text:
                        'Fundamentally, player contracts operate in a very similar way to team contracts. There are however a few key differences. \n\n When it comes to players, what we are interested in is where each individual ranks in terms of "player points". This is calculated based on a set of rules very similar to that of fantasy football. For the full list of how these points are calculated click the button below. '),
              ],
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return PointsExplainer();
            }));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Points calculation \n explained',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 15),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text:
                        'In each league there are 200 elligible players which are chosen based on their perfromance from the previous season. They can then acrue points during games played in their respective league matches. (International and non-league matches, such as the FA cup, do not contribute). '),
                TextSpan(
                    text:
                        'Only these 200 players are ranked, even if there are other non-listed players which would otherwise enter the ranking',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(
                    text:
                        '\n\n There are only two types of contract you can buy for a player: long, and short. The long contract pays out more and more the higher a player ranks in the points table, from a minimum of £0.05 for last place up to £10.00 for firt place. That means the contract rises in value by 5p for each rank. \n\n Similarly, the short contract has a maximum payout of £10.00 for last place, a 5p payout for first place, and decreased linearly for any position between the two. ')
              ],
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );

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
                    canTapOnHeader: true,
                    isExpanded: isExpanded[i],
                    headerBuilder: (context, expanded) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _generateTitle(questions[i]),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: i == 2 ? playerContract : _generateBody(answers[i]),
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
