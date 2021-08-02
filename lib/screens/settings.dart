import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/authentication/authenication_provider.dart';
import 'login/gatekeeper.dart';
import '../utils/widgets/dialogues.dart';
import 'login/login_utils.dart';

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
      ],
    );
  }
}

InputDecoration createTextDecoration(String hint) {
  OutlineInputBorder _boxBorder({required Color color, required double width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    focusedBorder: _boxBorder(color: Colors.blue, width: 3.0),
    enabledBorder: _boxBorder(color: Colors.blue, width: 3.0),
    errorBorder: _boxBorder(color: Colors.red, width: 1.5),
    focusedErrorBorder: _boxBorder(color: Colors.red, width: 1.5),
    filled: true,
    hintStyle: new TextStyle(color: Colors.blue, fontSize: 17),
    hintText: hint,
    fillColor: Colors.transparent,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  );
}

class ChangeUsername extends StatefulWidget {
  @override
  _ChangeUsernameState createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _username;
  bool loading = false;
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: Container(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // confirm password
                SizedBox(
                  width: 300,
                  height: 60,
                  child: TextFormField(
                    autocorrect: false,
                    obscureText: false,
                    validator: (newusername) {
                      if (!isValidUsername(newusername!)) {
                        return 'Username must be between 4 and 20 characters';
                      }
                      return null;
                    },
                    onChanged: (newusername) {
                      _username = newusername;
                    },
                    onSaved: (newusername) {
                      _username = newusername;
                    },
                    style: TextStyle(color: Colors.blue, fontSize: 17),
                    decoration: createTextDecoration('New username'),
                  ),
                ),
                SizedBox(height: 20),
                ButtonTheme(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minWidth: 300,
                  height: 50,
                  child: TextButton(
                    child: loading
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ))
                        : Text(
                            'CONFIRM',
                            style: TextStyle(color: Colors.blue, fontSize: 18, letterSpacing: 1),
                          ),
                    onPressed: _username == null
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              // close the keyboard
                              if (!FocusScope.of(context).hasPrimaryFocus) {
                                FocusManager.instance.primaryFocus!.unfocus();
                              }

                              setState(() {
                                loading = true;
                              });

                              AuthService _auth = AuthService();

                              // register user and check for problems
                              String? error = await _auth.updateUsername(_username!);
                              DocumentSnapshot result = await FirebaseFirestore.instance.collection('users').doc(_auth.currentUid).get();

                              for (String pid in result['portfolios']) {
                                DocumentReference portfolioDoc = await FirebaseFirestore.instance.collection('portfolios').doc(pid);
                                await portfolioDoc.update({'username': _username});
                              }

                              await Future.delayed(Duration(seconds: 2));

                              // if no problems happened with registering, push to verification stage
                              if (error == null) {
                                Navigator.of(context).pop(true);
                              }

                              // otherwise display error
                              else {
                                setState(() {
                                  errorText = error;
                                  loading = false;
                                });
                              }
                            }
                          },
                  ),
                ),
                (errorText == '') ? Container() : Container(height: 20, child: Text(errorText, style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        ));
  }
}

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _password1;
  bool loading = false;
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: Container(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  height: 60,
                  child: TextFormField(
                    autocorrect: false,
                    // controller: _pass,
                    obscureText: true,
                    validator: (String? password1) {
                      if (!isValidPassword(password1!)) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                    onSaved: (String? password1) {
                      this._password1 = password1;
                    },
                    style: TextStyle(color: Colors.blue, fontSize: 17),
                    decoration: createTextDecoration('New password'),
                  ),
                ),
                SizedBox(height: 5),
                // confirm password
                SizedBox(
                  width: 300,
                  height: 60,
                  child: TextFormField(
                    autocorrect: false,
                    obscureText: true,
                    validator: (password2) {
                      if (!isValidPassword(password2!)) {
                        return 'Password must be at least 8 characters';
                      }
                      if (password2 != _password1) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onSaved: (password2) {
                      // this._password2 = password2;
                    },
                    style: TextStyle(color: Colors.blue, fontSize: 17),
                    decoration: createTextDecoration('Retype password'),
                  ),
                ),
                SizedBox(height: 20),
                ButtonTheme(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minWidth: 300,
                  height: 50,
                  child: TextButton(
                    child: loading
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ))
                        : Text(
                            'RESET PASSWORD',
                            style: TextStyle(color: Colors.blue, fontSize: 18, letterSpacing: 1),
                          ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // close the keyboard
                        if (!FocusScope.of(context).hasPrimaryFocus) {
                          FocusManager.instance.primaryFocus!.unfocus();
                        }

                        // save the form state
                        _formKey.currentState!.save();

                        setState(() {
                          loading = true;
                        });

                        // register user and check for problems
                        String? error = await AuthService().updatePassword(_password1!);

                        await Future.delayed(Duration(seconds: 2));

                        // if no problems happened with registering, push to verification stage
                        if (error == null) {
                          Navigator.of(context).pop(true);
                        }

                        // otherwise display error
                        else {
                          setState(() {
                            errorText = error;
                            loading = false;
                          });
                        }
                      }
                    },
                  ),
                ),
                (errorText == '') ? Container() : Container(height: 20, child: Text(errorText, style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        ));
  }
}
