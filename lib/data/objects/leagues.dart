import 'package:cloud_firestore/cloud_firestore.dart';

class League {

  /// class for representing a league, e.g. Premier League or Bundesliga
  /// Generally instantiated from a firebase query
  
  String? id;
  String? name;
  String? country;
  String? countryFlagEmoji;
  DateTime? startDate;
  DateTime? endDate;
  String? imageURL;
  int? leagueID;

  Map<String, Map>? playerTable;
  Map<String, Map>? teamTable;

  League(this.id);

  League.fromSnapshot(DocumentSnapshot snapshot){

    id = snapshot.id;
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    name = data['name'];
    country = data['country'];
    countryFlagEmoji = data['emojii'];
    startDate = data['start_date'].toDate();
    endDate = data['end_date'].toDate();
    imageURL = data['image'];
    leagueID = data['league_id'];

    playerTable =Map<String, Map>.from(data['tables']['players']);
    teamTable = Map<String, Map>.from(data['tables']['teams']); 

  }

}

Future<League> getLeagueById(String id) async {
  return League.fromSnapshot(await FirebaseFirestore.instance.collection('leagues').doc(id).get());
}