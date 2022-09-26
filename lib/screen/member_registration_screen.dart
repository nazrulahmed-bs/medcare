import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:medicine/my_assets.dart';
import 'package:medicine/my_helper.dart';
import 'package:medicine/screen/member_login_screen.dart';

class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<MemberRegistrationScreen> createState() =>
      _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final TextEditingController tecEmail = TextEditingController();
  final TextEditingController tecName = TextEditingController();
  final TextEditingController tecPass = TextEditingController();
  final TextEditingController tecMemberCode = TextEditingController();

  Future<bool> signUp(
      {required String email,
      required String password,
      required name,
      required memberCode}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      //_firebaseDatabase.ref('patient/$memberCode').push().set({"name": name});
      _firebaseDatabase
          .ref('member/${userCredential.user!.uid}')
          .push()
          .set({"mc": memberCode});

      return true;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message!)));
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
              Text(
                'Join as a member',
                style: TextStyle(fontSize: 24),
              ),
              verticalGap(30),
              TextFormField(
                controller: tecMemberCode,
                decoration: const InputDecoration(hintText: "Member Code"),
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
                        name: tecName.text,
                        memberCode: tecMemberCode.text);
                    if (isSuccess) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MemberLoginScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Something went wrong. try again!')));
                    }
                  },
                  child: const Text('Registration')),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => MemberLoginScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Already have an account?'),
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
