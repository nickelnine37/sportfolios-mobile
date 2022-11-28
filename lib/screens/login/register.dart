import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/login/gdpr.dart';

import 'gatekeeper.dart';
import 'login_utils.dart';
import 'verify.dart';

class AccountRegistrationPage extends StatefulWidget {
  AccountRegistrationPage({Key? key}) : super(key: key);

  @override
  _AccountRegistrationPageState createState() => _AccountRegistrationPageState();
}

class _AccountRegistrationPageState extends State<AccountRegistrationPage> {
  /// these are all helper varables to handle the fade-in transition
  bool _isVisible = false;
  int _pauseTime = 300;
  int _fadeInTime = 700; //milli

  @override
  void initState() {
    super.initState();

    /// wait for [_pauseTime] and then set visible to true
    /// this triggers rebuild and animates the opacity
    Future.delayed(
      Duration(milliseconds: _pauseTime),
      () {
        setState(() {
          _isVisible = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, iconTheme: IconThemeData(color: Colors.white)),
      backgroundColor: Colors.blue[200],
      body: AnimatedOpacity(
        curve: Curves.easeInOutQuart,
        opacity: _isVisible ? 1 : 0,
        duration: Duration(milliseconds: _fadeInTime),
        child: SingleChildScrollView(
          child: Center(child: AccountRegistrationForm()),
        ),
      ),
    );
  }
}

class AccountRegistrationForm extends StatefulWidget {
  AccountRegistrationForm({Key? key}) : super(key: key);

  @override
  _AccountRegistrationFormState createState() => _AccountRegistrationFormState();
}

class _AccountRegistrationFormState extends State<AccountRegistrationForm> {
  //
  String? _email;
  String? _username;
  String? _password1;
  String? errorText;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  GateKeeper? gateKeeper;

  bool loading = false;
  bool _privacyConfirmed = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _pass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// gatekeeper needs context, so must be set here
    /// check if its null to avoid creating again on re-build
    if (gateKeeper == null) {
      gateKeeper = GateKeeper(context);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 70),
        Text('Set up an account', style: TextStyle(fontSize: 22, color: Colors.white)),
        SizedBox(height: 70),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // email input
              SizedBox(
                width: 300,
                height: 60,
                child: TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  validator: (email) {
                    if (!isValidEmail(email!)) {
                      return 'Please input a valid email address';
                    }
                    return null;
                  },
                  onSaved: (email) {
                    this._email = email;
                  },
                  style: TextStyle(color: Colors.white, fontSize: 17),
                  decoration: createTextInput('Email'),
                ),
              ),
              SizedBox(height: 5),
              // username input
              SizedBox(
                width: 300,
                height: 60,
                child: TextFormField(
                  autocorrect: false,
                  validator: (String? username) {
                    if (!isValidUsername(username!)) {
                      return 'Username must be between 5 and 20 characters';
                    }
                    return null;
                  },
                  onSaved: (String? username) {
                    this._username = username;
                  },
                  style: TextStyle(color: Colors.white, fontSize: 17),
                  decoration: createTextInput('Username'),
                ),
              ),
              SizedBox(height: 5),
              // password input
              SizedBox(
                width: 300,
                height: 60,
                child: TextFormField(
                  autocorrect: false,
                  controller: _pass,
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
                  style: TextStyle(color: Colors.white, fontSize: 17),
                  decoration: createTextInput('Password'),
                ),
              ),
              SizedBox(height: 5),
              // confirm password
              SizedBox(
                width: 300,
                height: 60,
                child: TextFormField(
                  autocorrect: false,
                  controller: _confirmPass,
                  obscureText: true,
                  validator: (password2) {
                    if (!isValidPassword(password2!)) {
                      return 'Password must be at least 8 characters';
                    }
                    if (password2 != _pass.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onSaved: (password2) {
                    // this._password2 = password2;
                  },
                  style: TextStyle(color: Colors.white, fontSize: 17),
                  decoration: createTextInput('Retype password'),
                ),
              ),
              SizedBox(height: 5),
              // GDPR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    checkColor: Colors.blue[400],
                    fillColor: MaterialStateProperty.all(Colors.white),
                    value: _privacyConfirmed,
                    onChanged: (bool? value) {
                      setState(() {
                        _privacyConfirmed = value!;
                      });
                    },
                  ),
                  Text(
                    'I agree to the',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return PrivacyPolicy();
                            },
                          ),
                        );
                      },
                      child: Text('privacy policy'))
                ],
              ),
              SizedBox(height: 15),

              // register button
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ))
                      : Text(
                          'REGISTER',
                          style: TextStyle(color: _privacyConfirmed ? Colors.white : Colors.grey[300], fontSize: 18, letterSpacing: 1),
                        ),
                  onPressed: loading || !_privacyConfirmed
                      ? null
                      : () async {
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
                            String? error = await gateKeeper!.registerUser(email: _email!, username: _username, password: _password1!);
                            await Future.delayed(Duration(seconds: 2));

                            // if no problems happened with registering, push to verification stage
                            if (error == null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return VerifyScreen(email: _email);
                                  },
                                ),
                              );
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
            ],
          ),
        ),
        SizedBox(height: 13),
        (errorText == null) ? Container() : Container(height: 20, child: Text(errorText!, style: TextStyle(color: Colors.red))),
      ],
    );
  }
}
