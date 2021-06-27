import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// final AutoDisposeStreamProvider<SportfoliosUser>? authenticationProvider = StreamProvider.autoDispose<SportfoliosUser>((ref) {
//   return AuthService().userStream;
// });

/// a class to handle basic authentication tasks
class AuthService {
  // for interacting with firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid {
    return _auth.currentUser!.uid;
  }

  // Stream<SportfoliosUser> get userStream {
  //   return _auth
  //       .userChanges()
  //       .where((User? user) => user!.emailVerified)
  //       .map((User? user) => SportfoliosUser(user));
  // }

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
    } on FirebaseAuthException catch (error)  {
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
      users
          .doc(result.user!.uid)
          .set({'portfolios': []}).catchError((error) => print("Failed to add user database entry: $error"));
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
    await _auth.currentUser!.reload();
    return _auth.currentUser!.emailVerified;
  }
}
