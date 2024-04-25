import 'package:flutter/material.dart';
import 'package:v1/emailauth/auth.dart';
// import 'package:v1/emailauth/pages/landing_page.dart';
import 'package:v1/emailauth/pages/loginpage.dart';
import 'package:v1/screens/LandingPage.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WidgetTreeState();
  }
}

class _WidgetTreeState extends State<WidgetTree> {
  // String userEmail = Auth().currentUser!.email!;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LandingPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
