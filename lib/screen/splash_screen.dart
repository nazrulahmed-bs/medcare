import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicine/local_data.dart';
import 'package:medicine/my_assets.dart';
import 'package:medicine/my_helper.dart';
import 'package:medicine/screen/home_screen.dart';
import 'package:medicine/screen/member_home_screen.dart';
import 'package:medicine/screen/user_type_selection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    User? user = getUser();
    final LocalData localData = LocalData();
    localData.getUser().then((value) {
      LocalData.uid = value;
    });
    localData.getType().then((value) {
      LocalData.type = value;
    });

    Future.delayed(const Duration(seconds: 2)).then((value) {
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => UserTypeScreen()));
      } else {
        if (LocalData.type == 'member') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => MemberHomeScreen()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                MyAssets.appLogo,
                width: 150,
              ),
            ),
            verticalGap(30),
            const Text(
              MyAssets.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalGap(30),
            const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }

  User? getUser() {
    try {
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException {
      return null;
    }
  }
}
