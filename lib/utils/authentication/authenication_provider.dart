import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// a class to handle basic authentication tasks
class AuthService {
  // for interacting with firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid {
    return _auth.currentUser!.uid;
  }

  String get username {
    return _auth.currentUser!.displayName!;
  }

  String get email {
    return _auth.currentUser!.email!;
  }

  void signOut() {
    _auth.signOut();
    print('Signing user out');
  }

  Future<FirebaseAuthException?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (error) {
      print('Login error: ' + error.message!);
      return error;
    }
  }

  Future<FirebaseAuthException?> sendResetPasswordEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (error) {
      print('Error sending password reset: ${error.message}');
      return error;
    }
  }

  Future<FirebaseAuthException?> createNewUser({
    required String email,
    required String? username,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await result.user!.updateDisplayName(username);
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      users.doc(result.user!.uid).set({
        'portfolios': [],
        'username': result.user!.displayName,
        'comments': {}, 
        'liked_portfolios': []
      }).catchError(
        (error) => print("Failed to add user database entry: $error"),
      );
      return null;
    } on FirebaseAuthException catch (error) {
      print('Error creating new user: ' + error.message!);
      return error;
    }
  }

  /// senda verification email to the curent user
  Future<FirebaseAuthException?> sendVerificationEmail() async {
    if (_auth.currentUser != null) {
      try {
        await _auth.currentUser!.sendEmailVerification();
        return null;
      } on FirebaseAuthException catch (error) {
        print('Error sending verification email: ${error.message}');
        return error;
      }
    } else {
      print('Cannot send verification email as user is null');
      return null;
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (error) {
      print('Error updating password: ${error.message}');
      return error.message;
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  Future<String?> updateUsername(String newUsername) async {
    try {
      await _auth.currentUser!.updateDisplayName(newUsername);
      return null;
    } on FirebaseAuthException catch (error) {
      print('Error updating username: ${error.message}');
      return error.message;
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  /// refresh the token??? Needed sometimes
  /// https://stackoverflow.com/questions/47243702/firebase-token-email-verified-going-weird
  Future<void> refreshToken() async {
    await _auth.currentUser!.getIdToken(true);
  }

  Future<String> getJWTToken() async {
    return await _auth.currentUser!.getIdToken(false);
  }

  /// check whether there is a current user signed in,
  /// and whether that user is email-verified
  Future<bool> isVerified() async {
    // if there is no user signed in, return false
    if (_auth.currentUser == null) return false;
    // else reload user details, and check if they're email-verified
    print(_auth.currentUser);
    
    await _auth.currentUser!.reload();
    return _auth.currentUser!.emailVerified;
  }
}
