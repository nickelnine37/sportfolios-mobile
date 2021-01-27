import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportfolios_alpha/data/models/base.dart';

class League extends BaseDataModel {

  /// class for representing a league, e.g. Premier League or Bundesliga
  /// Generally instantiated from a firebase query

  String name;
  String country;
  String countryFlagEmoji;
  DateTime startDate;
  DateTime endDate;
  String imageURL;
  int leagueID;

  League(String documentId) : super(documentId);

  League.fromSnapshot(DocumentSnapshot snapshot) : super(snapshot.id) {

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