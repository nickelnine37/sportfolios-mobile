import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/screens/login/login_utils.dart';

class PasswordResetPage extends StatefulWidget {
  PasswordResetPage({Key key}) : super(key: key);

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  String _email;
  String _bottomText =
      "Enter your email above. If you've registered an account, a link will be sent for you to reset your password. ";
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
                      'Reset your password',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                                decoration: createTextInput('Email')),
                          ),
                          SizedBox(height: 15),
                          ButtonTheme(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              minWidth: 300,
                              height: 50,
                              child: RaisedButton(
                                elevation: 0,
                                child: Text(
                                  'SEND RESET LINK',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      letterSpacing: 1),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    setState(() {
                                      _bottomText =
                                          'Email sent. Follow the link to reset your password';
                                    });
                                    print(
                                        'sending password reset to ${this._email}');
                                    _authService.sendResetPasswordEmail(
                                        email: this._email);
                                  }
                                },
                              )),
                        ])),
                    SizedBox(height: 70),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 55),
                        child: Text(
                          _bottomText,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.justify,
                        )),
                  ]),
            ),
          ),
        ));
  }
}
