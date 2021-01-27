import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/all.dart';
import 'package:sportfolios_alpha/data/models/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final authenticationProvider = StreamProvider.autoDispose<SportfoliosUser>((ref) {
  return AuthService().userStream;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SportfoliosUser get user {
  //   return SportfoliosUser(_auth.currentUser);
  // }

  String get currentUid {
    return _auth.currentUser.uid;
  }

  Stream<SportfoliosUser> get userStream {
    return _auth
        .userChanges()
        .where((User user) => user.emailVerified)
        .map((User user) => SportfoliosUser(user));
  }

  void signOut() {
    _auth.signOut();
    print('Signing user out');
  }

  Future<FirebaseAuthException> signInWithEmail({@required String email, @required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (error) {
      print('Login error: ' + error.message);
      return error;
    }
  }

  Future<FirebaseAuthException> sendResetPasswordEmail({@required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (error) {
      print('Error sending password reset' + error.message);
      return error;
    }
  }

  Future<FirebaseAuthException> createNewUser({
    @required String email,
    @required String username,
    @required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await result.user.updateProfile(displayName: username);
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      users
          .doc(result.user.uid)
          .set({'portfolios': []})
          .catchError((error) => print("Failed to add user database entry: $error"));
      return null;
    } on FirebaseAuthException catch (error) {
      print('Error creating new user: ' + error.message);
      return error;
    }
  }

  Future<FirebaseAuthException> sendVerificationEmail() async {
    if (_auth.currentUser != null) {
      try {
        await _auth.currentUser.sendEmailVerification();
        return null;
      } on FirebaseAuthException catch (error) {
        print('Error sending verification email: ' + error.message);
        return error;
      }
    } else {
      print('Cannot send verification email as user is null');
      return null;
    }
  }

  Future<bool> isVerified() async {
    if (_auth.currentUser == null) {
      return false;
    }
    await _auth.currentUser.reload();
    return _auth.currentUser.emailVerified;
  }
}
