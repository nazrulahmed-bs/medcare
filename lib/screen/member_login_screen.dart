import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medicine/local_data.dart';
import 'package:medicine/my_assets.dart';
import 'package:medicine/my_helper.dart';
import 'package:medicine/screen/member_home_screen.dart';
import 'package:medicine/screen/member_registration_screen.dart';

class MemberLoginScreen extends StatefulWidget {
  MemberLoginScreen({Key? key}) : super(key: key);

  @override
  _MemberLoginScreenState createState() => _MemberLoginScreenState();
}

class _MemberLoginScreenState extends State<MemberLoginScreen> {
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
              verticalGap(30),
              Text(
                'Login as a member',
                style: TextStyle(fontSize: 24),
              ),
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
                        MaterialPageRoute(builder: (_) => MemberHomeScreen()));
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
                          builder: (_) => const MemberRegistrationScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Not a member yet '),
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

  Future<bool> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final localData = LocalData();
      localData.storeUser(userCredential.user!.uid);
      localData.setType('member');
      LocalData.uid = userCredential.user!.uid;
      print('uid:: ${LocalData.uid}');
      DataSnapshot data = await FirebaseDatabase.instance
          .ref('member')
          .child(LocalData.uid!)
          .get();
      print('data child: ${data.children}');
      Map<dynamic, dynamic> mc =
          data.children.first.value as Map<dynamic, dynamic>;
      final memberCode = mc['mc'];
      print("MC:::::::$memberCode");
      FirebaseMessaging.instance.subscribeToTopic(memberCode);

      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }
}
