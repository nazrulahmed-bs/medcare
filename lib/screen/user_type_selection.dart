import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicine/local_data.dart';
import 'package:medicine/my_assets.dart';
import 'package:medicine/my_helper.dart';
import 'package:medicine/screen/login_screen.dart';
import 'package:medicine/screen/member_login_screen.dart';
import 'package:medicine/screen/member_registration_screen.dart';
import 'package:medicine/screen/registration_screen.dart';

class UserTypeScreen extends StatefulWidget {
  UserTypeScreen({Key? key}) : super(key: key);

  @override
  _UserTypeScreenState createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController tecEmail = TextEditingController();
  final TextEditingController tecPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                  child: Image.asset(
                MyAssets.appLogo,
                width: 150,
              )),
              verticalGap(50),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: const Text(
                    'Login as a Patient',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              verticalGap(50),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => MemberLoginScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: const Text(
                    'Login as a Member',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              verticalGap(50),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => RegistrationScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: const Text(
                    'Join as a Patient',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              verticalGap(50),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MemberRegistrationScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: const Text(
                    'Join as a Member',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // 3
  Future<bool> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      LocalData().storeUser(userCredential.user!.uid);
      LocalData.uid = userCredential.user!.uid;
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }
}
