import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/settings/faqs.dart';
import 'package:sportfolios_alpha/screens/settings/unpw.dart';
import 'package:sportfolios_alpha/utils/authentication/authenication_provider.dart';
import '../login/gatekeeper.dart';
import '../../utils/widgets/dialogues.dart';
import '../login/login_utils.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  GateKeeper? gateKeeper;

  @override
  Widget build(BuildContext context) {
    if (gateKeeper == null) {
      gateKeeper = GateKeeper(context);
    }

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                child: Row(
                  children: [
                    Text('Sign out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    SizedBox(
                      width: 4,
                    ),
                    Icon(Icons.exit_to_app)
                  ],
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return BasicDialog(
                          title: 'Confirm',
                          description: 'Are you sure you want to sign out?',
                          buttonText: 'Confirm',
                          action: () {
                            gateKeeper!.exit();
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
  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 100,
          padding: EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 25),
                Icon(Icons.account_circle_rounded, size: 50),
                SizedBox(width: 25),
                SizedBox(
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _authService.username,
                        style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(_authService.email),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Divider(thickness: 2),
        ListTile(
          leading: Text(
            'Change username',
            style: TextStyle(fontSize: 16.0),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () async {
            bool? success = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return ChangeUsername();
                },
              ),
            );

            if (success ?? false) {
              setState(() {});
            }
          },
        ),
        Divider(thickness: 2),
        ListTile(
          leading: Text(
            'Change password',
            style: TextStyle(fontSize: 16.0),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () async {
            bool? success = await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
              return ChangePassword();
            }));
          },
        ),
        Divider(thickness: 2),
        ListTile(
          leading: Text(
            'FAQs',
            style: TextStyle(fontSize: 16.0),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => FAQs()));
          },
        ),
                Divider(thickness: 2),

      ],
    );
  }
}

