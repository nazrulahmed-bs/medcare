import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:medicine/local_data.dart';
import 'package:medicine/screen/notification_screen.dart';
import 'package:medicine/screen/user_type_selection.dart';

class MemberHomeScreen extends StatefulWidget {
  String? remoteData;

  MemberHomeScreen({super.key, this.remoteData});

  @override
  _MemberHomeScreenState createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  int currentIndex = 0;
  late FlutterTts flutterTts;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isSpeaking = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<Map> medData = [];

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.awaitSpeakCompletion(true).then((value) => print(value));
  }

  @override
  void initState() {
    super.initState();
    _initFCM();
    initTts();
    if (widget.remoteData != null) {
      _speak(widget.remoteData!);
    }
  }

  Future _speak(String msg) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    if (msg.isNotEmpty) {
      await flutterTts.speak(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine App - Member'),
        actions: [
          IconButton(
              onPressed: () async {
                await signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => UserTypeScreen()));
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: widget.remoteData != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.remoteData.toString()),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isSpeaking = false;
                        });
                      },
                      child: Text('Ok'),
                    ),
                  )
                ],
              )
            : Text('No notification for this time'),
      ),
    );
  }

  void setSpeakingTimer() async {
    isSpeaking = true;
    while (isSpeaking) {
      _speak(widget.remoteData ?? 'Medicine timer for the patient');
      await Future.delayed(Duration(seconds: 3));
    }
  }

  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      LocalData().logout();
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  void showMedicine(DataSnapshot element) {
    Map<String, dynamic> data = element as Map<String, dynamic>;
    final col = data['col'];
    final doc = data['doc'];
    final dbRef = FirebaseFirestore.instance;
    dbRef.collection(col).doc(doc).get().then((value) => print(value.data()));
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      var now = DateTime.now();

      for (Map data in medData) {
        var time = DateFormat('hh:mm').parse(data['time']);

        if (time.difference(now) > const Duration(seconds: 1)) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      NotificationScreen(doc: data['doc'], col: data['col'])));
        }
      }
    });
  }

  void _initFCM() async {
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
    FirebaseMessaging.onMessage.listen((event) {
      setState(() {
        widget.remoteData = event.data['title'];
        setSpeakingTimer();
      });
    });
  }
}
