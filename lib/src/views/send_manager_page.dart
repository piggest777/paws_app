import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/batch_delivery.dart';
import 'package:paws_app/src/views/batch_delivery_details_page.dart';
import 'package:paws_app/src/views/box_scanning_page.dart';
import 'package:paws_app/src/views/view_components/batch_delivery_card.dart';

class SentItemsManagerPage extends StatelessWidget {
  const SentItemsManagerPage({Key? key}) : super(key: key);

  Future<void> _createNewBatchDelivery(BuildContext context) async {
    // Get the current counter value and increment it
    var counterRef = FirebaseFirestore.instance
        .collection('counters')
        .doc('batchDeliveryID');
    var counterSnapshot = await counterRef.get();
    int currentId = (counterSnapshot.data()?['current'] ?? 0) as int;
    await counterRef.update({'current': FieldValue.increment(1)});

    // Create a new batch delivery
    DateTime now = DateTime.now();

    var newBatchDelivery = BatchDelivery(
      id: currentId.toString(),
      date: now,
      day: now.day,
      month: now.month,
      year: now.year,
      boxList: [], // initial boxList
    );

    // Add the new batch delivery to Firestore
    await FirebaseFirestore.instance
        .collection('batchDeliveries')
        .doc(newBatchDelivery.id)
        .set(newBatchDelivery.toMap());

    // Navigate to the box scanning page with the new batch delivery ID
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          BatchDeliveryDetailsPage(batchDeliveryId: newBatchDelivery.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sent Items"),
      ),
      body: buildBatchDeliveryList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewBatchDelivery(context),
        heroTag: 'sentItemsFAB',
        child: const Icon(Icons.add),
        tooltip: 'Create New Batch Delivery',
      ),
    );
  }

  Widget buildBatchDeliveryList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('batchDeliveries').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('No batch deliveries found');
        }
        var deliveries = snapshot.data!.docs
            .map((doc) => BatchDelivery.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        return ListView.builder(
          itemCount: deliveries.length,
          itemBuilder: (context, index) {
            return BatchDeliveryCard(delivery: deliveries[index]);
          },
        );
      },
    );
  }
}
