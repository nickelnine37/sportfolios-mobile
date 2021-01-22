import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/screens/login/gatekeeper.dart';
import 'package:sportfolios_alpha/screens/login/login_utils.dart';
import 'package:sportfolios_alpha/screens/login/register.dart';
import 'package:sportfolios_alpha/screens/login/reset_password.dart';

/// Main login widget. This consists of three pages:
/// 1. The main login page, for users who aldready have an account
/// 2. A register page, where users can register a new account
/// 3. A fogot-my-password page, where users can be sent an email
/// with a link to reset their password.
class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email;
  String _password;
  String errorText = '';
  GateKeeper gateKeeper;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isVisible = false;
  bool _isStart = true;
  int fadeInTime = 500; //milliseconds
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _isStart
        ? Future.delayed(Duration(milliseconds: fadeInTime), () {
            setState(() {
              _isVisible = true;
              _isStart = false;
            });
          })
        : _isVisible = true;
  }

  @override
  Widget build(BuildContext context) {

    if (gateKeeper == null) {
      gateKeeper = GateKeeper(context);
    }

    return Scaffold(
      //  resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: AnimatedOpacity(
        curve: Curves.easeInOutQuart,
        opacity: _isVisible ? 1 : 0,
        duration: Duration(milliseconds: fadeInTime),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[300], Colors.white],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 140),
                  Image.asset('assets/images/sportfolios.png', width: 270),
                  SizedBox(height: 70),
                  Form(
                      key: _formKey,
                      child: Column(children: [
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
                              decoration: createTextInput('Your email')),
                        ),
                        // email input
                        SizedBox(height: 5),
                        SizedBox(
                          width: 300,
                          height: 60,
                          child: TextFormField(
                            autocorrect: false,
                            obscureText: true,
                            validator: (password) {
                              if (!isValidPassword(password))
                                return 'Password must be at least 8 characters';
                              else
                                return null;
                            },
                            onSaved: (password) {
                              this._password = password;
                            },
                            style: TextStyle(color: Colors.white, fontSize: 17),
                            decoration: createTextInput('Your password'),
                          ),
                        ),
                        // password input
                        SizedBox(height: 25),
                        ButtonTheme(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          minWidth: 300,
                          height: 50,
                          child: RaisedButton(
                            elevation: 0,
                            child: isLoading
                                ? Container(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                      strokeWidth: 3,
                                    ))
                                : Text('LOGIN',
                                    style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1)),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                // close the keyboard
                                if (!FocusScope.of(context).hasPrimaryFocus) {
                                  FocusManager.instance.primaryFocus.unfocus();
                                }

                                // save the form state
                                _formKey.currentState.save();

                                // add loading indicator
                                setState(() {
                                  isLoading = true;
                                });

                                // attempt sign in
                                gateKeeper
                                    .enter(email: this._email, password: this._password)
                                    .then((value) {
                                  // on fail, display error text
                                  setState(() {
                                    errorText = value;
                                    isLoading = false;
                                  });
                                });
                              }
                            },
                          ),
                        ),
                      ])),
                  SizedBox(height: 15),
                  Container(height: 20, child: Text(errorText, style: TextStyle(color: Colors.red))),
                  SizedBox(height: 8),

                  // FORGOT PASSWORD
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
                        return PasswordResetPage();
                      }));
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.blue[400]),
                    ),
                  ),
                  SizedBox(height: 140),

                  // REGISTER
                  Text("Don't have an account yet?", style: TextStyle(color: Colors.blue[400], fontSize: 17)),
                  SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
                        return AccountRegistrationPage();
                      }));
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
