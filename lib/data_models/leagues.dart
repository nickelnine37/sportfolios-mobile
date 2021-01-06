import 'package:cloud_firestore/cloud_firestore.dart';


class League {

  /// class for representing a league, e.g. Premier League or Bundesliga
  /// Generally instantiated from a firebase query

  String name;
  String country;
  String countryFlagEmoji;
  DateTime startDate;
  DateTime endDate;
  String imageURL;
  int leagueID;

  League(this.name, this.country, this.countryFlagEmoji, this.startDate, this.endDate, this.imageURL);

  League.fromMap(Map map) {
    name = map['name'];
    country = map['country'];
    countryFlagEmoji = map['emojii'];
    startDate = map['start_date'].toDate();
    endDate = map['end_date'].toDate();
    imageURL = map['image'];
    leagueID = map['league_id'];
  }

}

Future<List<League>> getLeagues() async {

  List leagues = <League>[];

  QuerySnapshot data = await FirebaseFirestore.instance.collection('leagues').get();

    data.docs.forEach((result) {
      leagues.add(League.fromMap(result.data()));
    });

  await Future.delayed(Duration(seconds: 1), () => 12);

  return leagues;
}