import 'package:flutter/material.dart';

import '../../providers/authenication_provider.dart';
import 'login_utils.dart';

/// Main Password Rest Page Widget
class PasswordResetPage extends StatefulWidget {
  PasswordResetPage({Key? key}) : super(key: key);

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  /// these are all helper varables to handle the fade-in transition
  bool _isVisible = false;
  int _pauseTime = 300;
  int _fadeInTime = 700; //milliseconds

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

        /// main child is a scrollable view holding the password reset form
        child: SingleChildScrollView(
          child: Center(
            child: PasswordResetForm(),
          ),
        ),
      ),
    );
  }
}

/// Widget to handle the main password reset logic
class PasswordResetForm extends StatefulWidget {
  PasswordResetForm({Key? key}) : super(key: key);

  @override
  _PasswordResetFormState createState() => _PasswordResetFormState();
}

class _PasswordResetFormState extends State<PasswordResetForm> {
  /// the user's email
  String? _email;

  /// text to display at the bottom
  String _bottomText =
      "Enter your email above. If you've registered an account, a link will be sent for you to reset your password. ";

  /// global key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// auth service for resetting password ([GateKeeper] not needed here)
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 70),
        Text('Reset your password', style: TextStyle(fontSize: 22, color: Colors.white)),
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
                      if (!isValidEmail(email!)) {
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
              SizedBox(height: 15),
              ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minWidth: 300,
                height: 50,
                child: RaisedButton(
                  elevation: 0,
                  child: Text(
                    'SEND RESET LINK',
                    style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {

                     // close the keyboard
                      if (!FocusScope.of(context).hasPrimaryFocus) {
                        FocusManager.instance.primaryFocus!.unfocus();
                      }

                      // save the form state
                      _formKey.currentState!.save();

                      // change the bottom text
                      setState(() {
                        _bottomText = 'Email sent. Follow the link to reset your password';
                      });
                      print('sending password reset to ${this._email}');
                      _authService.sendResetPasswordEmail(email: this._email!);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 70),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 55),
          child: Text(
            _bottomText,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
