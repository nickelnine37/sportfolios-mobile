import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/app_main.dart';
// import 'package:sportfolios_alpha/data_models/users.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/screens/login/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  final ThemeData theme = ThemeData(primaryColor: Colors.blue[200]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportFolios Alpha',
      theme: theme,
      home: LoginDirector(),
    );
  }

}

class LoginDirector extends StatelessWidget {
  final AuthService _auth = AuthService();

  // stream builder: when Authservice().user is null, return the login page. Else, return the main app
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _auth.userStream,
        initialData: LoginPage(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return AppMain();
          } else {
            return LoginPage();
          }
        });
  }
}


// RiverPod method...

// class LoginDirector extends ConsumerWidget {

//   final AuthService _auth = AuthService();

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {

//     Stream<User> user = watch(authenticationProvider.stream);

//     return StreamBuilder(stream: user,
//     initialData: LoginPage(),
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         return AppMain();
//       }
//       else {
//         return LoginPage();
//       }
//     });
//   }
// }