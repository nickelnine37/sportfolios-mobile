import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/providers/settings_provider.dart';
import 'package:sportfolios_alpha/screens/login/gatekeeper.dart';
import 'package:sportfolios_alpha/utils/widgets/dialogues.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  GateKeeper gateKeeper;

  // final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    if (gateKeeper == null) {
      gateKeeper = GateKeeper(context);
    }

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                child: Text('Sign out',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return BasicDialog(
                          title: 'Confirm',
                          description: 'Are you sure you want to sign out?',
                          buttonText: 'Confirm',
                          action: () {
                            gateKeeper.exit();
                          },
                        );
                      });
                },
              )
            ]),
            SizedBox(width: 15)
          ],
        ),
        body: SettingsBody());
  }
}

class SettingsBody extends StatefulWidget {
  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  @override
  Widget build(BuildContext context) {
    Container profileHeader = Container(
        width: double.infinity,
        height: 100,
        padding: EdgeInsets.all(10),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 25),
                Icon(Icons.account_circle_rounded, size: 50),
                SizedBox(width: 25),
                Consumer(builder: (context, watch, child) {
                  String uname =
                      watch(authenticationProvider).data?.value?.uname ?? '';
                  String email =
                      watch(authenticationProvider).data?.value?.email ?? '';
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(uname,
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[800])),
                      SizedBox(height: 2),
                      Text(email,
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[800])),
                    ],
                  );
                })
              ],
            )));

    return ListView(
      children: [
        profileHeader,
        Divider(thickness: 2),
        ListTile(
            leading: Text(
              'Currency',
              style: TextStyle(fontSize: 16.0),
            ),
            trailing: Consumer(builder: (context, watch, child) {
              return DropdownButton<String>(
                items: <String>['GBP', 'EUR', 'USD']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: watch(settingsProvider).currency,
                onChanged: (String value) {
                  context.read(settingsProvider).setCurrency(value);
                },
              );
            })),
        Divider(thickness: 2),
        // ListTile(
        //   leading: Text(
        //     'Public profile',
        //     style: TextStyle(fontSize: 16.0),
        //   ),
        //   trailing: Consumer(builder: (context, watch, child) {
        //     bool public =
        //         watch(authenticationProvider).data?.value?.public ?? false;
        //     return Switch(
        //       value: public,
        //       onChanged: (value) {},
        //     );
        //   }),
        // ),
        Divider(thickness: 2),
        ListTile(
          leading: Text(
            'Change password',
            style: TextStyle(fontSize: 16.0),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {},
        ),
        Divider(thickness: 2),
      ],
    );
  }
}
