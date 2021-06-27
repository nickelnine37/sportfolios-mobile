import 'package:flutter/material.dart';

import 'gatekeeper.dart';
import 'login_utils.dart';
import 'verify.dart';

class AccountRegistrationPage extends StatefulWidget {
  AccountRegistrationPage({Key key}) : super(key: key);

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
  AccountRegistrationForm({Key key}) : super(key: key);

  @override
  _AccountRegistrationFormState createState() => _AccountRegistrationFormState();
}

class _AccountRegistrationFormState extends State<AccountRegistrationForm> {
  //
  String _email;
  String _username;
  String _password1;
  String errorText;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  GateKeeper gateKeeper;

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

    ///
    /// the email input form field
    ///
    TextFormField emailInput = TextFormField(
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
      decoration: createTextInput('Email'),
    );

    ///
    /// the username input form field
    ///
    TextFormField usernameInput = TextFormField(
      autocorrect: false,
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
      decoration: createTextInput('Username'),
    );

    ///
    /// the first password input form field
    ///
    TextFormField passwordInput = TextFormField(
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
      decoration: createTextInput('Password'),
    );

    ///
    /// the second password input form field
    ///
    TextFormField confirmPasswordInput = TextFormField(
      autocorrect: false,
      controller: _confirmPass,
      obscureText: true,
      validator: (password2) {
        if (!isValidPassword(password2)) {
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
    );

    ///
    /// the register button
    ///
    ButtonTheme registerButton = ButtonTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      minWidth: 300,
      height: 50,
      child: RaisedButton(
        elevation: 0,
        child: Text(
          'REGISTER',
          style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1),
        ),
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();

            // close the keyboard
            if (!FocusScope.of(context).hasPrimaryFocus) {
              FocusManager.instance.primaryFocus.unfocus();
            }

            // save the form state
            _formKey.currentState.save();

            // register user and check for problems
            String error =
                await gateKeeper.registerUser(email: _email, username: _username, password: _password1);

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
              });
            }
          }
        },
      ),
    );

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
            children: [
              SizedBox(
                width: 300,
                height: 60,
                child: emailInput,
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 300,
                height: 60,
                child: usernameInput,
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 300,
                height: 60,
                child: passwordInput,
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 300,
                height: 60,
                child: confirmPasswordInput,
              ),
              SizedBox(height: 35),
              registerButton,
            ],
          ),
        ),
        SizedBox(height: 13),
        (errorText == null)
            ? Container()
            : Container(height: 20, child: Text(errorText, style: TextStyle(color: Colors.red))),
      ],
    );
  }
}
