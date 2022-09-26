import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  final doc;
  final col;

  NotificationScreen({super.key, required this.doc, required this.col});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final dbRef = FirebaseFirestore.instance;

  @override
  void initState() {
    dbRef
        .collection(widget.col)
        .doc(widget.doc)
        .get()
        .then((value) => print(value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
