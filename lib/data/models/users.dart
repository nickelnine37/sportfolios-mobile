import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class SportfoliosUser {

  final String uid;
  final String uname;
  final String email;
  
  SportfoliosUser._(this.uid, this.email, this.uname);

  factory SportfoliosUser(fb_auth.User user) {
    return user != null? SportfoliosUser._(user.uid, user.email, user.displayName) : null;
  }

@override
  String toString() {
  return 'User(${this.email}, ${this.uname})';
   }

}