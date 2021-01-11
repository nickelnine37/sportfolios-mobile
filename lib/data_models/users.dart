import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
// import 'package:flutter_riverpod/all.dart';
// import 'package:flutter/material.dart';

class User {

  final String uid;
  final String uname;
  final String email;

  bool public = true;
  
  User._(this.uid, this.email, this.uname);

  factory User(fb_auth.User user) {
    return user != null? User._(user.uid, user.email, user.displayName) : null;
  }

@override
  String toString() {
  return 'User(${this.email}, ${this.uname})';
   }

}