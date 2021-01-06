import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/screens/login/login_utils.dart';
import 'package:sportfolios_alpha/screens/login/register.dart';
import 'package:sportfolios_alpha/screens/login/reset_password.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  String _email;
  String _password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

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
        //  resizeToAvoidBottomInset: false,
        backgroundColor: Colors.blue[200],
        body: AnimatedOpacity(
          curve: Curves.easeInOutQuart,
          opacity: _isVisible ? 1 : 0,
          duration: Duration(milliseconds: 500),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 140),
                    Image.asset('assets/images/sportfolios.png', width: 270),
                    SizedBox(height: 70),
                    Form(
                        // autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: _formKey,
                        child: Column(children: [
                          SizedBox(
                            width: 300,
                            height: 60,
                            child: TextFormField(
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                                decoration: createTextInput('Your email')),
                          ),
                          // email input
                          SizedBox(height: 5),
                          SizedBox(
                            width: 300,
                            height: 60,
                            child: TextFormField(
                                obscureText: true,
                                validator: (password) {
                                  if (!isValidPassword(password)) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                                onSaved: (password) {
                                  this._password = password;
                                },
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                                decoration: createTextInput('Your password')),
                          ),
                          // password input
                          SizedBox(height: 25),
                          ButtonTheme(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              minWidth: 300,
                              height: 50,
                              child: RaisedButton(
                                elevation: 0,
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      letterSpacing: 1),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    _authService.signInWithEmail(
                                        email: this._email,
                                        password: this._password);
                                  }
                                },
                              )),
                        ])),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                          return SendPasswordResetEmail();
                        }));
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 140),
                    Text("Don't have an account yet?",
                        style: TextStyle(color: Colors.white, fontSize: 17)),
                    SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                          return Register();
                        }));
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 15),
                  ]),
            ),
          ),
        ));
  }
}