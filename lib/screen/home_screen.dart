import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicine/local_data.dart';
import 'package:medicine/screen/add_medicine.dart';
import 'package:medicine/screen/all_medicine.dart';
import 'package:medicine/screen/medicine_reminder.dart';
import 'package:medicine/screen/members.dart';
import 'package:medicine/screen/notificationservice.dart';
import 'package:medicine/screen/user_type_selection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    NotificationService().initNotification((payload) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineReminder(payload: payload),
        ),
      );
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine App'),
        actions: [
          IconButton(
              onPressed: () async {
                await signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserTypeScreen(),
                  ),
                );
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMedicine(),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    height: 100,
                    child: const Center(
                        child: Text(
                      'Add Medicine',
                      style: TextStyle(fontSize: 30),
                    )),
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () async {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) => AddMedicine(),
                  //     ));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    height: 100,
                    child: const Center(
                        child: Text(
                      'Edit Medicine',
                      style: TextStyle(fontSize: 30),
                    )),
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllMedicine(),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    height: 100,
                    child: const Center(
                        child: Text(
                      'All Medicine',
                      style: TextStyle(fontSize: 30),
                    )),
                  ),
                )),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          currentIndex = index;
          setState(() {});
          if (index == 2) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => Members()));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Members",
          ),
        ],
      ),
    );
  }

  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      LocalData().logout();
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }
}
