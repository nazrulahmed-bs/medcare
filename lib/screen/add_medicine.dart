import 'dart:io';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:medicine/local_data.dart';
import 'package:medicine/my_helper.dart';
import 'package:medicine/screen/notificationservice.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({Key? key}) : super(key: key);

  @override
  _AddMedicineState createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  TimeOfDay selectedTime = TimeOfDay.now();
  TextEditingController tecName = TextEditingController();
  TextEditingController tecDoses = TextEditingController();
  TextEditingController tecStartTime = TextEditingController();
  TextEditingController tecQuantity = TextEditingController();
  TextEditingController tecType = TextEditingController();
  TextEditingController tecFrequency = TextEditingController();

  String imageUrl = '';
  File? image;

  bool isLoading = false;

  final picker = ImagePicker();
  final storageRef = FirebaseStorage.instance.ref();
  final dbRef = FirebaseFirestore.instance;
  final firebaseRealTimeDbRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            TextFormField(
              controller: tecName,
              decoration: const InputDecoration(
                hintText: "Medicine Name",
              ),
            ),
            TextFormField(
              controller: tecDoses,
              decoration: const InputDecoration(
                hintText: "Doses",
              ),
              keyboardType: TextInputType.number,
            ),
            verticalGap(20),
            InkWell(
              onTap: () => _selectTime(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Start time',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '${selectedTime.hour}:${selectedTime.minute}',
                    style: const TextStyle(fontSize: 20),
                  ),

                  /// TODO: add other fields
                ],
              ),
            ),
            TextFormField(
              controller: tecQuantity,
              decoration: const InputDecoration(
                hintText: "Medicine Quantity",
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: tecType,
              decoration: const InputDecoration(
                hintText: "Type - capsule",
              ),
              keyboardType: TextInputType.text,
            ),
            TextFormField(
              controller: tecFrequency,
              decoration: const InputDecoration(
                hintText: "Frequency - 2 times a day",
              ),
              keyboardType: TextInputType.number,
            ),
            verticalGap(30),
            InkWell(
              onTap: () async {
                captureImage();
              },
              child: image == null
                  ? DottedBorder(
                      color: Colors.grey,
                      strokeWidth: 1,
                      child: const Center(
                          child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.0),
                        child: Text('Upload medicine image'),
                      )),
                    )
                  : Stack(
                      children: [
                        Image.file(image!),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.redAccent,
                              ),
                              onPressed: () {
                                image = null;
                                setState(() {});
                              },
                              child: Text('Remove X')),
                        )
                      ],
                    ),
            ),
            verticalGap(30),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      if (image == null) {
                        _showSnackbar("Please add an image!");
                        return;
                      } else if (tecName.text.isEmpty) {
                        _showSnackbar("Please enter the medicine name!");
                        return;
                      } else if (tecQuantity.text.isEmpty) {
                        _showSnackbar("Please enter the medicine quantity!");
                        return;
                      } else if (tecFrequency.text.isEmpty) {
                        _showSnackbar("Please enter the medicine frequency !");
                        return;
                      } else if (tecType.text.isEmpty) {
                        _showSnackbar("Please enter the medicine type !");
                        return;
                      } else if (tecDoses.text.isEmpty) {
                        _showSnackbar("Please enter the medicine doses!");
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });

                      final imgRef = storageRef
                          .child(LocalData.uid!)
                          .child(image!.path.split('/').last);
                      TaskSnapshot taskSnapshot = await imgRef.putFile(image!);
                      imageUrl = await taskSnapshot.ref.getDownloadURL();

                      DocumentReference data =
                          await dbRef.collection(LocalData.uid!).add({
                        "name": tecName.text,
                        "doses": tecDoses.text,
                        "frequency": tecFrequency.text,
                        "qty": tecQuantity.text,
                        "time": '${selectedTime.hour}:${selectedTime.minute}',
                        "type": tecType.text,
                        "image": imageUrl,
                      });
                      int random = Random().nextInt(200);

                      NotificationService().showNotification(
                          random,
                          "MEDICINE REMINDER",
                          tecName.text,
                          imageUrl,
                          data.id,
                          selectedTime);

                      final currentDate = DateTime.now();
                      AndroidAlarmManager.periodic(
                        Duration(days: 1),
                        random,
                        sendPushNotificationToMembers,
                        startAt: DateTime(
                            currentDate.year,
                            currentDate.month,
                            currentDate.day,
                            selectedTime.hour,
                            selectedTime.minute),
                        allowWhileIdle: true,
                        rescheduleOnReboot: true,
                      );

                      firebaseRealTimeDbRef
                          .child('patient')
                          .child(LocalData.uid!.toLowerCase().substring(0, 5))
                          .child('noti')
                          .push()
                          .set({
                        'col': LocalData.uid!,
                        'doc': data.id,
                        'time': '${selectedTime.hour}:${selectedTime.minute}'
                      });

                      setState(() {
                        isLoading = false;
                        Navigator.pop(context);
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child:
                          Text('Add Medicine', style: TextStyle(fontSize: 20)),
                    ),
                  ),
            verticalGap(30),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        });

    if (picked_s != null && picked_s != selectedTime) {
      setState(() {
        selectedTime = picked_s;
      });
    }
  }

  captureImage() async {
    //Get the file from the image picker and store it
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {});
    } else {
      print('No image selected.');
      return;
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static void sendPushNotificationToMembers() {
    try {
      http
          .get(Uri.parse(
              'http://nazrulahmed.xyz/medcare/send_push.php?token=${LocalData.uid!.substring(0, 5).toLowerCase()}&title=Medicine time for your patient&body=This is Medicine time for your patient'))
          .then((value) => print('value is :::::$value"'));
    } catch (e) {
      print(e.toString());
    }
  }
}
