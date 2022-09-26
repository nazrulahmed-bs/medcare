import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medicine/my_assets.dart';
import 'package:medicine/my_helper.dart';
import 'package:medicine/screen/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final TextEditingController tecEmail = TextEditingController();
  final TextEditingController tecName = TextEditingController();
  final TextEditingController tecPass = TextEditingController();

  Future<bool> signUp(
      {required String email, required String password, required name}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      _firebaseDatabase.ref(userCredential.user!.uid).set({"name": name});

      return true;
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              verticalGap(90),
              Center(
                child: Image.asset(
                  MyAssets.appLogo,
                  width: 150,
                ),
              ),
              verticalGap(30),
              TextFormField(
                controller: tecName,
                decoration: const InputDecoration(hintText: "Full Name"),
              ),
              verticalGap(30),
              TextFormField(
                controller: tecEmail,
                decoration: const InputDecoration(hintText: "Email"),
              ),
              verticalGap(30),
              TextFormField(
                controller: tecPass,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Password"),
              ),
              verticalGap(30),
              ElevatedButton(
                  onPressed: () async {
                    if (tecEmail.text.isEmpty || tecPass.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill all the field')));
                    }
                    bool isSuccess = await signUp(
                        email: tecEmail.text,
                        password: tecPass.text,
                        name: tecName.text);
                    if (isSuccess) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => LoginScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Something went wrong. try again!')));
                    }
                  },
                  child: const Text('Registration')),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Allready have an account?'),
                    Text('login now!', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
