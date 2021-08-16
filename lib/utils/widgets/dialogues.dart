import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/objects/leagues.dart';

class BasicDialog extends StatelessWidget {
  final String title, description, buttonText;
  final void Function() action;

  BasicDialog({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    const double padding = 30;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(top: padding, left: padding, right: padding),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(padding),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Text(
              this.title,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Text(description, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 24.0),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                  this.action();
                },
                child: Text(buttonText),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LeagueSelectorDialogue extends StatelessWidget {
  final List<League> leagues;

  const LeagueSelectorDialogue(this.leagues);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 400,
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
                child: Text('Select a league', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Container(
              height: 340,
              child: ListView.separated(
                itemCount: leagues.length,
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text(leagues[i].name!),
                    leading: Container(
                      width: 35,
                      height: 35,
                      child: CachedNetworkImage(imageUrl: leagues[i].imageURL!),
                    ),
                    trailing: Text(leagues[i].countryFlagEmoji!),
                    onTap: () {
                      Navigator.of(context).pop(leagues[i].leagueID);
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

class SortByDialogue extends StatelessWidget {
  final List<String> options = [
    'Value (high to low)',
    'Value (low to high)',
    'Position (top to bottom)',
    'Position (bottom to top)',
    '24h return (high to low)',
    '24h return  (low to high)',
    'Week return (high to low)',
    'Week return (low to high)',
    'Month return (high to low)',
    'Month return  (low to high)',
    'All time return (high to low)',
    'All time return (low to high)',
  ];

  final List<List<dynamic>> sortBy = [
    ['long_price_current', true],
    ['long_price_current', false],
    ['position', false],
    ['position', true],
    ['long_price_returns_d', true],
    ['long_price_returns_d', false],
    ['long_price_returns_w', true],
    ['long_price_returns_w', false],
    ['long_price_returns_m', true],
    ['long_price_returns_m', false],
    ['long_price_returns_M', true],
    ['long_price_returns_M', false],
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 412,
        padding: EdgeInsets.all(16),
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
                child: Text('Sort by', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Container(
              height: 340,
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text(options[i]),
                    // leading: Container(
                    // width: 35,
                    // height: 35,
                    // child: CachedNetworkImage(imageUrl: leagues[i].imageURL!),
                    // ),
                    // trailing: Text(options[i]),
                    onTap: () {
                      Navigator.of(context).pop(sortBy[i]);
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

// need to further adjust this
class SeasonSelectorDialogue extends StatelessWidget {
  final List<String>? seasons;

  const SeasonSelectorDialogue(this.seasons);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 400,
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
                child: Text('Select a season', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Container(
              height: 340,
              child: ListView.separated(
                itemCount: seasons!.length,
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text(seasons![i]),
                    onTap: () {
                      Navigator.of(context).pop(seasons![i]);
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
