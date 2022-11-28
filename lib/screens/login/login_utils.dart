import 'package:flutter/material.dart';

/// helper function for creating stylised text input boxes
InputDecoration createTextInput(String hint) {

  OutlineInputBorder _boxBorder({required Color color, required double width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    focusedBorder: _boxBorder(color: Colors.white, width: 3.0),
    enabledBorder: _boxBorder(color: Colors.white, width: 3.0),
    errorBorder: _boxBorder(color: Colors.red, width: 1.5),
    focusedErrorBorder: _boxBorder(color: Colors.red, width: 1.5),
    filled: true,
    hintStyle: new TextStyle(color: Colors.white, fontSize: 17),
    hintText: hint,
    fillColor: Colors.transparent,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  );
}

bool isValidEmail(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}

bool isValidPassword(String password) {
  return (password.length > 7);
}

bool isValidUsername(String username) {
  return (username.length > 4 && username.length < 20);
}

// RegExp(r"^[a-zA-Z0-9]+([_ -.]?[a-zA-Z0-9])*$").hasMatch(username)