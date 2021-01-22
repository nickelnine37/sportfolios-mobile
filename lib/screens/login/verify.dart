import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/screens/login/gatekeeper.dart';

class VerifyScreen extends StatefulWidget {

  final String email;
  VerifyScreen({@required this.email});

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  GateKeeper gateKeeper;

  @override
  Widget build(BuildContext context) {
    if (gateKeeper == null) {
      gateKeeper = GateKeeper(context);
      gateKeeper.sendVerificationEmail();
      gateKeeper.awaitVerification();
    }

    return Scaffold(
      appBar: AppBar(elevation: 0, iconTheme: IconThemeData(color: Colors.white)),
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(35),
              child: Text(
                'Click the link in the email sent to ${widget.email} to confirm your account',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
