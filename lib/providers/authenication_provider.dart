import 'package:riverpod/all.dart';
import 'package:sportfolios_alpha/data_models/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final authenticationProvider = StreamProvider.autoDispose<SportfoliosUser>((ref) {
  return AuthService().userStream;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SportfoliosUser get user {
    return SportfoliosUser(_auth.currentUser);
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
      }
      on FirebaseAuthException catch (error) {
        print('Error sending verification email: ' + error.message);
        return error;
      }
    }
    else {
      print('Cannot send verification email as user is null');
      return null;
    }
    
  }

  bool isVerified() {
    if (_auth.currentUser == null) {
      return false;
    }
    _auth.currentUser.reload();
    return _auth.currentUser.emailVerified;
  }
}
