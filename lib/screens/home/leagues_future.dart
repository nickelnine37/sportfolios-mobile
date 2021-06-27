import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/objects/leagues.dart';
import 'app_bar.dart';

// this gets called only when a sport has been selected
class HomeBody extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final String selectedSport;

  final Map<String, String> photos = {
    'Tennis': 'https://i.ytimg.com/vi/PO4V7SRDdH4/maxresdefault.jpg',
    'Golf':
        'https://www.golfchannel.com/sites/golfchannel.prod.acquia-sites.com/files/siem_456_towelonface_2012.jpg',
    'Rugby': 'https://www.rnz.co.nz/assets/news/132869/eight_col_Shaun_Johnson_sad.jpg?1511000327',
    'Cricket': 'https://i.dawn.com/primary/2019/07/5d261e8aa08da.jpg',
    'American Football': 'https://nflfaninengland.files.wordpress.com/2010/02/sad_vince.jpg',
    'Basketball':
        'http://cdn1-www.mandatory.com/assets/uploads/2015/03/sad-lebron-james-2-e1425339915613.jpg',
    'Baseball': 'https://americaswhiteboy.com/wp-content/uploads/2013/03/Sad+New+York+Mets+Fan+MLB.jpg',
  };

  final List<String> supportedSports = ['Football'];

  HomeBody({@required this.selectedSport, @required this.parentScaffoldKey});

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  Future<List<League>> _leaguesFuture;
  String _lastLoadedSport;
  int initialLeagueId;

  @override
  void initState() {
    super.initState();
    _leaguesFuture = _getLeagues(widget.selectedSport);
  }

  Future<List<League>> _getLeagues(String sport) async {
    _lastLoadedSport = sport;
    if (sport == 'Football') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      initialLeagueId = prefs.getInt('selectedLeague') ?? 8;
      QuerySnapshot result = await FirebaseFirestore.instance.collection('leagues').get();
      return result.docs
          .map((DocumentSnapshot leagueSnapshot) => League.fromSnapshot(leagueSnapshot))
          .toList();
    } else {
      return [];
    }
  }

  Scaffold _buildScaffold({String title, Widget body}) {
    return Scaffold(
      body: body,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white),),
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.menu),
          onPressed: () {
            widget.parentScaffoldKey.currentState.openDrawer();
          },
        ),
      ),
    );
  }

  Widget _apologise(String sport) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Coming soon', style: TextStyle(fontSize: 25)),
          SizedBox(height: 20),
          Text("Sorry, ${sport.toLowerCase()} is not available yet :'( "),
          SizedBox(height: 20),
          CachedNetworkImage(
            imageUrl: widget.photos[sport],
            width: MediaQuery.of(context).size.width * 0.9,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//
    // we've just switched sports, so load the new leagues
    if (_lastLoadedSport != widget.selectedSport) {
      setState(() {
        _leaguesFuture = _getLeagues(widget.selectedSport);
      });
    }

    return FutureBuilder(
      future: _leaguesFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // loading a new sport
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildScaffold(title: '', body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          List<League> leagues = snapshot.data;

          // no leagues for this sport yet
          if (leagues.length == 0) {
            return _buildScaffold(title: widget.selectedSport, body: _apologise(widget.selectedSport));
          } else {
            return MainView(
              sport: widget.selectedSport,
              leagues: leagues,
              initialLeagueId: initialLeagueId,
              drawerKey: widget.parentScaffoldKey,
            );
          }
        } else if (snapshot.hasError) {
          return _buildScaffold(title: 'Error :(', body: Center(child: Text("That's an error, I'm afraid")));
        } else {
          return _buildScaffold(title: '', body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
