import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/app_main.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/screens/login/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// It all begins here...
void main() async {
  /// run these two lines to ensure Firebase is up and running
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// wrap the whole app in a riverpod [ProviderScope]
  runApp(ProviderScope(child: MyApp()));
}

/// Main stateless widget for the whole app
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// use this to check whether a user is verified
  Future<bool> verifiedUser;

  /// set some theme data
  final ThemeData theme = ThemeData(primaryColor: Colors.blue[200]);

  /// check whether the user is verified here
  @override
  void initState() {
    verifiedUser = AuthService().isVerified();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// our main app widget returns a Material app
    return MaterialApp(
      title: 'SportFolios Alpha',
      theme: theme,

      /// use FutureBuilder while we wait to find out whether user is verified
      home: FutureBuilder(
        future: verifiedUser,
        builder: (context, snapshot) {
          /// run this block when we've completed the verification request
          if (snapshot.connectionState == ConnectionState.done) {
            /// future will return a bool
            bool userIsVerified = snapshot.data;

            /// user is verified
            if (userIsVerified)
              return AppMain();

            /// user is not verified
            else
              return LoginPage();
          }

          /// if we have an error
          else if (snapshot.hasError) {
            /// just direct them to the login screen...
            print('Error checking user verification status: ${snapshot.error}');
            return LoginPage();
          }

          /// we're still checking... just show a blank screen
          else {
            return BlankPage();
          }
        },
      ),
    );
  }
}

/// helper widget that just returns a blank page with some colour gradient
class BlankPage extends StatelessWidget {
  const BlankPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[300], Colors.white],
          ),
        ),
      ),
    );
  }
}
