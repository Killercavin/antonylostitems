import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportedItemsScreen extends StatelessWidget {
  final CollectionReference lostItemsCollection =
  FirebaseFirestore.instance.collection('lost_items');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reported Items")),
      body: StreamBuilder<QuerySnapshot>(
        stream: lostItemsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text("Error: ${snapshot.error}");
          if (!snapshot.hasData) return CircularProgressIndicator();

          var items = snapshot.data!.docs;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              var data = items[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['item_name']),
                subtitle: Text("Status: ${data['status']}"),
                trailing: IconButton(
                  icon: Icon(Icons.verified, color: Colors.green),
                  onPressed: () => _verifyItem(items[index].id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _verifyItem(String docId) async {
    await lostItemsCollection.doc(docId).update({'status': 'verified'});
  }
}
