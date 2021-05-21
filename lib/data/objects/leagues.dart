import 'package:cloud_firestore/cloud_firestore.dart';

class League {

  /// class for representing a league, e.g. Premier League or Bundesliga
  /// Generally instantiated from a firebase query
  
  String id;
  String name;
  String country;
  String countryFlagEmoji;
  DateTime startDate;
  DateTime endDate;
  String imageURL;
  int leagueID;

  League(this.id);

  League.fromSnapshot(DocumentSnapshot snapshot){

    id = snapshot.id;
    Map<String, dynamic> data = snapshot.data();

    name = data['name'];
    country = data['country'];
    countryFlagEmoji = data['emojii'];
    startDate = data['start_date'].toDate();
    endDate = data['end_date'].toDate();
    imageURL = data['image'];
    leagueID = data['league_id'];
  }

}