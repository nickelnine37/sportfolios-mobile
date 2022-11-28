import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'leagues_future.dart';

/// the primary purpose of this parent widget for the Home page is to provide a scaffold with a
/// drawer where various options can be selected. This includes which sport the user is #
/// currently looking at, and an about dialogue. The only slightly tricky thing is that the
/// drawer needs to be above the rest of the widget tree. That way, the new sport can be passed
/// down the widget tree, triggering a new database call etc. To acheive this, we need a
/// [GlobalKey] which can be used to open and close the drawer by the app bar, which is lower
/// down the tree. (There are actually three [Scaffold]s here, one for the base navigation
/// bar in app_main, one for the drawer here, and one for the AppBar and body lower down.)
class Home extends StatefulWidget {
  final List<String> sports = [
    'Football',
    'Tennis',
    'Rugby',
    'Cricket',
    'Golf',
    'American Football',
    'Basketball',
    'Baseball',
  ];
  final List<IconData> sportIcons = [
    Icons.sports_soccer,
    Icons.sports_tennis,
    Icons.sports_rugby,
    Icons.sports_cricket,
    Icons.sports_golf,
    Icons.sports_football,
    Icons.sports_basketball,
    Icons.sports_baseball,
  ];

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedSport = 'Football';

  // this is a special about tile
  // Does Google just insist on this for no reason...?
  // https://api.flutter.dev/flutter/material/AboutListTile-class.html
  // AboutListTile aboutTile = ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: HomeBody(selectedSport: _selectedSport, parentScaffoldKey: _scaffoldKey),
      drawer: Drawer(
        child: ListView.separated(
          itemCount: widget.sports.length + 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0)
              return DrawerHeader(
                child: Center(
                  child: Image.asset(
                    'assets/images/sportfolios.png',
                    width: 200,
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[300]!, Colors.grey[50]!],
                  ),
                ),
              );
            else if (index == widget.sports.length + 1)
              return AboutListTile(
                icon: Icon(Icons.info),
                applicationIcon: FlutterLogo(size: 43),
                applicationName: 'Sportfolios',
                applicationVersion: 'V0.1 - January 2021',
                // applicationLegalese: '\u{a9} 2014 The Flutter Authors',
                aboutBoxChildren: [
                  SizedBox(height: 24),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        style: TextStyle(color: Colors.grey[700]),
                        text:
                            'Thank you for being part of the Sportfolios Alpha - we look forward to your feedback! Feel free to get in touch with Ed and Cole any time at '),
                    TextSpan(
                      text: 'admin@sportfolios.co.uk',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          String _url = 'mailto:admin@sportfolios.co.uk';
                          void _launchURL() async => await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
                          _launchURL();
                        },
                    ),
                    TextSpan(style: TextStyle(color: Colors.grey[700]), text: '.'),
                  ]))
                ],
              );
            else
              return ListTile(
                title: Text(widget.sports[index - 1]),
                leading: Icon(widget.sportIcons[index - 1]),
                visualDensity: VisualDensity(horizontal: 0, vertical: 0),
                onTap: () {
                  // new sport selected, so trigger rebuild of appbar and body children
                  setState(() {
                    _selectedSport = widget.sports[index - 1];
                  });
                  Navigator.of(context).pop();
                },
              );
          },
          separatorBuilder: (BuildContext context, int index) {
            if (index == 0)
              return Container();
            else
              return Divider(thickness: 1, height: 1);
          },
        ),
      ),
    );
  }
}
