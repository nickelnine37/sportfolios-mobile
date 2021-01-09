import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/screens/login/login_utils.dart';

class AccountRegistrationPage extends StatefulWidget {
  AccountRegistrationPage({Key key}) : super(key: key);

  @override
  _AccountRegistrationPageState createState() =>
      _AccountRegistrationPageState();
}

class _AccountRegistrationPageState extends State<AccountRegistrationPage> {
  String _email;
  String _username;
  String _password1;
  // String _password2;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  bool _isVisible = false;
  bool _isStart = true;

  @override
  void initState() {
    super.initState();
    _isStart
        ? Future.delayed(Duration(milliseconds: 1000), () {
            setState(() {
              _isVisible = true;
              _isStart = false;
            });
          })
        : _isVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(elevation: 0, iconTheme: IconThemeData(color: Colors.white)),
      backgroundColor: Colors.blue[200],
      body: AnimatedOpacity(
        curve: Curves.easeInOutQuart,
        opacity: _isVisible ? 1 : 0,
        duration: Duration(milliseconds: 400),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 70),
                Text(
                  'Set up an account',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                SizedBox(height: 70),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 300,
                        height: 60,
                        child: TextFormField(
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            validator: (email) {
                              if (!isValidEmail(email)) {
                                return 'Please input a valid email address';
                              }
                              return null;
                            },
                            onSaved: (email) {
                              this._email = email;
                            },
                            style: TextStyle(color: Colors.white, fontSize: 17),
                            decoration: createTextInput('Email')),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: 300,
                        height: 60,
                        child: TextFormField(
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            validator: (String username) {
                              if (!isValidUsername(username)) {
                                return 'Username must be between 5 and 20 characters';
                              }
                              return null;
                            },
                            onSaved: (String username) {
                              this._username = username;
                            },
                            style: TextStyle(color: Colors.white, fontSize: 17),
                            decoration: createTextInput('Username')),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: 300,
                        height: 60,
                        child: TextFormField(
                            autocorrect: false,
                            controller: _pass,
                            obscureText: true,
                            validator: (String password1) {
                              if (!isValidPassword(password1)) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                            onSaved: (String password1) {
                              this._password1 = password1;
                            },
                            style: TextStyle(color: Colors.white, fontSize: 17),
                            decoration: createTextInput('Password')),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: 300,
                        height: 60,
                        child: TextFormField(
                            autocorrect: false,
                            controller: _confirmPass,
                            obscureText: true,
                            validator: (password2) {
                              if (!isValidPassword(password2)) {
                                return 'Password must be at least 8 characters';
                              }
                              if (password2 != _pass.text) {
                                return 'Passwords must match';
                              }
                              return null;
                            },
                            onSaved: (password2) {
                              // this._password2 = password2;
                            },
                            style: TextStyle(color: Colors.white, fontSize: 17),
                            decoration: createTextInput('Retype password')),
                      ),
                      SizedBox(height: 35),
                      ButtonTheme(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        minWidth: 300,
                        height: 50,
                        child: RaisedButton(
                          elevation: 0,
                          child: Text(
                            'REGISTER',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 1),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              _authService.createNewUser(
                                  email: this._email,
                                  username: this._username,
                                  password: this._password1);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
