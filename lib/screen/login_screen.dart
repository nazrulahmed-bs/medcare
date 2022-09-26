import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medicine/local_data.dart';
import 'package:medicine/my_assets.dart';
import 'package:medicine/my_helper.dart';
import 'package:medicine/screen/home_screen.dart';
import 'package:medicine/screen/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
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
              verticalGap(30),
              TextFormField(
                controller: tecEmail,
                decoration: const InputDecoration(hintText: "Email"),
              ),
              TextFormField(
                controller: tecPass,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
              ),
              verticalGap(20),
              ElevatedButton(
                onPressed: () async {
                  if (tecEmail.text.isEmpty || tecPass.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all the field')));
                  }
                  bool isSuccess = await signIn(
                      email: tecEmail.text, password: tecPass.text);
                  if (isSuccess) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid login credential!')));
                  }
                },
                child: const Text('Login'),
              ),
              verticalGap(50),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegistrationScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('New to medicine app? '),
                    Text('join now!', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              )
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
