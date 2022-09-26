import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:medicine/local_data.dart';

class MedicineReminder extends StatefulWidget {
  final String? payload;

  const MedicineReminder({super.key, this.payload});

  @override
  _MedicineReminderState createState() => _MedicineReminderState();
}

class _MedicineReminderState extends State<MedicineReminder> {
  String medicineName = '';
  String medicineImg = '';
  String doses = '';
  bool isSpeaking = false;
  late FlutterTts flutterTts;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  final firestore = FirebaseFirestore.instance;
  void getMedicineInfo() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await firestore.collection(LocalData.uid!).doc(widget.payload).get();
    final data = documentSnapshot.data();
    medicineName = data!['name'];
    medicineImg = data['image'];
    doses = data['doses'];
    setSpeakingTimer();

    setState(() {});
  }

  @override
  initState() {
    super.initState();
    initTts();
    getMedicineInfo();
  }

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.awaitSpeakCompletion(true).then((value) => print(value));
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
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Reminder'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  medicineName,
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Center(
                child: Text(
                  'doses: $doses',
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Center(
                child: Container(
                  height: 300,
                  child: medicineImg == ''
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Image.network(medicineImg),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSpeaking = false;
                    });
                  },
                  child: Text('Done'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void setSpeakingTimer() async {
    isSpeaking = true;
    while (isSpeaking) {
      _speak('$medicineName $doses dose');
      await Future.delayed(Duration(seconds: 3));
    }
  }
}
