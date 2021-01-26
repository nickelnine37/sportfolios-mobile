import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/app_main.dart';
import 'package:sportfolios_alpha/providers/authenication_provider.dart';
import 'package:sportfolios_alpha/screens/login/login.dart';

class GateKeeper {
  AuthService _authService = AuthService();
  BuildContext context;

  GateKeeper(this.context);

  Future<void> checkForCurrentUser() async {
    if (await _authService.isVerified()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return AppMain();
          },
        ),
      );
    }
  }

  Future<String> enter({@required String email, @required String password}) async {
    FirebaseAuthException signInProblem =
        await _authService.signInWithEmail(email: email, password: password);
    if (signInProblem == null) {
      if (await _authService.isVerified()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return AppMain();
            },
          ),
        );
        return 'Success';
      } else {
        return 'Click the email verification link to sign in';
      }
    } else {
      return 'Unable to sign in. Check your details and try again';
    }
  }

  void exit() {
    _authService.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return LoginPage();
      },
    ));
  }

  Future<String> registerUser({
    @required String email,
    @required String username,
    @required String password,
  }) async {
    FirebaseAuthException newUserProblem =
        await _authService.createNewUser(email: email, username: username, password: password);
    if (newUserProblem == null) {
      return null;
    } else {
      if (newUserProblem.code == 'email-already-in-use') {
        return 'Email already in use';
      } else if (newUserProblem.code == 'invalid-email') {
        return 'Invalid email. Please try again';
      } else if (newUserProblem.code == 'weak-password') {
        return 'Password is too weak. Please try again';
      }
      print('Error creating new user: ${newUserProblem.code} -  ${newUserProblem.message}');
      return 'Error creating new user';
    }
  }

  Future<String> sendVerificationEmail() async {
    FirebaseAuthException verificationResult = await _authService.sendVerificationEmail();
    if (verificationResult == null) {
      return null;
    } else {
      print('Error sending verification email: ${verificationResult.code} - ${verificationResult.message}');
      return 'Error sending verification email. Try again later';
    }
  }

  Future<void> awaitVerification() async {
    int i = 0;
    Timer.periodic(
      Duration(seconds: 5),
      (timer) async {
        print('Waiting: ${i++}');
        if (await _authService.isVerified()) {
          timer.cancel();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return AppMain();
              },
            ),
          );
        }
      },
    );
  }
}
