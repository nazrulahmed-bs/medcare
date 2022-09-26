import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicine/local_data.dart';

class AllMedicine extends StatefulWidget {
  const AllMedicine({Key? key}) : super(key: key);

  @override
  State<AllMedicine> createState() => _AllMedicineState();
}

class _AllMedicineState extends State<AllMedicine> {
  final cloudRef = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Medicine'),
      ),
      body: FutureBuilder(
        future: getMedicine(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot.data!.docs.first.data());
            return ListView.builder(
                itemBuilder: (ctx, index) {
                  final medicine = snapshot.data!.docs[index].data();
                  return Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(
                              height: 300,
                              child: FadeInImage.assetNetwork(
                                placeholder:
                                    'assets/images/placeholder_medicine.jpg',
                                image: medicine['image'],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            medicine['name'],
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'doses: ${medicine['doses']}',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'time: ${medicine['time']}',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'type: ${medicine['type']}',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'frequency: ${medicine['frequency']}',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: snapshot.data!.docs.length);
          }
          return Text('');
        },
      ),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMedicine() {
    return cloudRef.collection(LocalData.uid!).get();
  }
}
