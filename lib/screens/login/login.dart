import 'package:flutter/material.dart';

import 'gatekeeper.dart';
import 'login_utils.dart';
import 'register.dart';
import 'reset_password.dart';

/// Main login widget. This consists of three pages:
/// 1. The main login page, for users who already have an account. This is where we start
/// 2. A register page, where users can register a new account
/// 3. A fogot-my-password page, where users can be sent an email with a link to reset their password.
/// Each page is split into two widgets: one main widget, which is a wire-frame containing all
/// the relevant sections, and a form widget which contains all the key logic for the page
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    /// variable is a [GestureDetector] (clickable) forgot password text. this redirects to the password reset page
    GestureDetector forgotPassword = GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (BuildContext context) {
            return PasswordResetPage();
          }),
        );
      },
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.blue[400]),
      ),
    );

    /// variable is a [GestureDetector] (clickable) sign up text
    /// this redirects to the sign up page
    GestureDetector signUp = GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext context) {
          return AccountRegistrationPage();
        }));
      },
      child: Text(
        'Sign up',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    /// main login view
    return Scaffold(
      backgroundColor: Colors.white,

      /// wrap the whole body in an animated opacity widget
      body: AnimatedOpacity(
        curve: Curves.easeInOutQuart,
        opacity: _isVisible ? 1 : 0,
        duration: Duration(milliseconds: _fadeInTime),

        /// main child is a scrollable view
        /// needs to be scrollable, as screen size reduced when keyboard goes up
        child: SingleChildScrollView(
          child: Container(
            /// spread the container to the width of the screen
            width: double.infinity,

            /// decorate background with gradient
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[300], Colors.white],
              ),
            ),

            /// main child is a column
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              /// children are a series of widgets
              children: [
                SizedBox(height: 140),
                Image.asset('assets/images/sportfolios.png', width: 270),
                SizedBox(height: 70),

                /// [LoginForm] contains email and password input and LOGIN button
                LoginForm(),

                /// [forgotPassword] FORGOT PASSWORD clickable
                forgotPassword,
                SizedBox(height: 140),

                /// [signUp] SIGN UP CLICKABLE
                Text("Don't have an account yet?", style: TextStyle(color: Colors.blue[400], fontSize: 17)),
                SizedBox(height: 14),
                signUp,
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// this forms the important part of the page
/// this is where the email and password fields are, as well as the login button
/// and a space to display an error message if necessary
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  /// variables for the user's email and password
  String _email;
  String _password;

  /// this will hold the error message, if any
  String _errorText = '';

  /// the [GateKeeper] is responsible for deciding whether to allows someone into the main app
  GateKeeper _gateKeeper;

  /// global key needed for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// this is set to true when the request is sent, and switches the
  /// button from 'LOGIN' to a progress indicator
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    /// create a new GateKeeper. need to do it here rather than in initState, as it needs context
    if (_gateKeeper == null) {
      _gateKeeper = GateKeeper(context);
    }

    /// email input form field
    TextFormField emailInput = TextFormField(
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        validator: (email) {
          /// email validation logic comes from login_utils
          if (!isValidEmail(email)) return 'Please input a valid email address';
          return null;
        },
        onSaved: (email) {
          this._email = email;
        },
        style: TextStyle(color: Colors.white, fontSize: 17),

        /// this style stuff comes from login_utils
        decoration: createTextInput('Your email'));

    /// password input form field
    TextFormField passwordInput = TextFormField(
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
    );

    /// LOGIN button
    ButtonTheme loginButton = ButtonTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      minWidth: 300,
      height: 50,
      child: RaisedButton(
        elevation: 0,
        child: _isLoading
            ? Container(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text('LOGIN', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1)),
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
              _isLoading = true;
            });

            // attempt sign in
            _gateKeeper.enter(email: this._email, password: this._password).then((value) {
              // on fail, display error text
              setState(() {
                if (value != 'Success') {
                  _errorText = value;
                }
                _isLoading = false;
              });
            });
          }
        },
      ),
    );

    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(width: 300, height: 60, child: emailInput),
              SizedBox(height: 5),
              SizedBox(width: 300, height: 60, child: passwordInput),
              SizedBox(height: 25),
              loginButton,
            ],
          ),
        ),
        SizedBox(height: 15),
        Container(height: 20, child: Text(_errorText, style: TextStyle(color: Colors.red))),
        SizedBox(height: 8),
      ],
    );
  }
}
