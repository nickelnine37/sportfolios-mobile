import 'package:riverpod/all.dart';
import 'package:sportfolios_alpha/data_models/users.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';

final authenticationProvider = StreamProvider.autoDispose<User>((ref) {

  return AuthService().user;
});

class AuthService {
  final _auth = fb_auth.FirebaseAuth.instance;

  Stream<User> get user {
    return _auth.authStateChanges().map((fb_auth.User user) => User(user));
  }

  void signOut() {
    _auth.signOut();
    print('Signing user out');
  }

  Future<User> signInWithEmail(
      {@required String email, @required String password}) async {
    try {
      fb_auth.UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      fb_auth.User user = result.user;
      print('User signed in successfully');
      // TODO: add email verification
      return User(user);
    } catch (e) {
      print(e.toString());
      return null;
      // TODO: handle different exceptions and update UI accordingly
    }
  }

  Future<void> sendResetPasswordEmail({@required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<User> createNewUser(
      {@required String email,
      @required String username,
      @required String password}) async {
    try {
      fb_auth.UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      fb_auth.User user = result.user;
      await user.updateProfile(displayName: username);
      // TODO: avoid username clashes?
      print(user.toString());
      return User(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
