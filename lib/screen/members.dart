import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:medicine/local_data.dart';

class Members extends StatefulWidget {
  const Members({Key? key}) : super(key: key);

  @override
  _MembersState createState() => _MembersState();
}

class _MembersState extends State<Members> {
  FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  List<String> users = [];
  Future getMembers() {
    return _firebaseDatabase
        .ref('patient/${LocalData.uid!.substring(0, 5).toLowerCase()}')
        .once();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: Container(
        child: FutureBuilder(
          future: getMembers(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                Map<dynamic, dynamic> members = snapshot.data!.snapshot.value;

                members.forEach((key, value) {
                  if (key == 'noti') {
                  } else {
                    print(value);
                    users.add(value['name']);
                  }
                });

                return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (ctx, int index) {
                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            users[index],
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    });
              } else {
                return const Center(
                  child: Text('No data available'),
                );
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const Center(
                child: Text('No data available'),
              );
            }
          },
        ),
      ),
      floatingActionButton: ElevatedButton(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Row(
            children: [
              const Text('Please share The Member code: '),
              Text(
                LocalData.uid!.substring(0, 5).toLowerCase(),
                style: const TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}
