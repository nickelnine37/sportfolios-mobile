import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_main.dart';
import 'utils/authentication/authenication_provider.dart';
import 'screens/login/login.dart';

/// It all begins here...
void main() async {
  /// run these two lines to ensure Firebase is up and running
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// wrap the whole app in a riverpod [ProviderScope]
  runApp(ProviderScope(child: MyApp()));
}

/// Main widget for the whole app
/// For now it is Stateful, as we need to use a FutureBuilder in the State to determine whether a user is logged in
/// Maybe a stream would be better, but as of yet I haven't fouond a way to build a stream that also accounts for 
/// whether a user has their email verified
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// use this to check whether a user is verified
  late Future<void> verificationFuture;
  late bool userIsVerified;

  /// set some theme data
  final ThemeData theme = ThemeData(primaryColor: Colors.blue[200]);

  /// check whether the user is verified here
  @override
  void initState() {
    verificationFuture = getVerificationStatus();
    super.initState();
  }

  Future<void> getVerificationStatus() async {
    userIsVerified = await AuthService().isVerified();
  }
 
  @override
  Widget build(BuildContext context) {
    /// our main app widget returns a Material app
    return MaterialApp(
      title: 'SportFolios Alpha',
      theme: theme,

      /// use FutureBuilder while we wait to find out whether user is verified
      home: FutureBuilder(
        future: verificationFuture,
        builder: (context, snapshot) {
          /// run this block when we've completed the verification request
          if (snapshot.connectionState == ConnectionState.done) {

            /// user is verified
            if (userIsVerified){
              print('User verified - continuing to app');
              return AppMain();
            }

            /// user is not verified
            else{
              print('User not verified - logging in');
              return LoginPage();
            }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[300]!, Colors.white],
          ),
        ),
      ),
    );
  }
}
