import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/views/view_components/barcode_view.dart';
import 'package:paws_app/src/views/view_components/counter_widget.dart';

class SupplyItemDetailsPage extends StatefulWidget {
  final PetCareSupply supplyItem; // PetCareSupply object (required)

  SupplyItemDetailsPage({required this.supplyItem});

  @override
  State<SupplyItemDetailsPage> createState() => _SupplyItemDetailsPageState();
}

class _SupplyItemDetailsPageState extends State<SupplyItemDetailsPage> {
  late int counterValue;
  late Stream<DocumentSnapshot> supplyItemStream;
  late FirebaseFirestore firestore;
  late StreamSubscription<DocumentSnapshot> supplyItemSubscription;

    @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    counterValue = widget.supplyItem.count;
    supplyItemStream = firestore.collection('petSupplyType')
        .doc(widget.supplyItem.id)
        .snapshots();
   supplyItemSubscription = supplyItemStream.listen((DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      if (mounted) {
        setState(() {
          counterValue = snapshot['count'] ?? 0;
        });
      }
    }
  });
  }

void _onSave(int updatedCount) {
  final supplyItemId = widget.supplyItem.id;
  final supplyItemRef = firestore.collection('petSupplyType').doc(supplyItemId);

  // Use SetOptions(merge: true) to create the field if it doesn't exist
  supplyItemRef.set({'count': updatedCount}, SetOptions(merge: true))
    .then((_) {
      // Successfully updated or created the field
    })
    .catchError((error) {
      // Handle the error
      print('Error updating count: $error');
    });
}

@override
void dispose() {
  supplyItemStream.drain();
  supplyItemSubscription.cancel();  // Cancel the subscription
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supply Item Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.supplyItem.barcode != null)
              BarcodeImageWidget(barcodeValue: widget.supplyItem.barcode!),
            SizedBox(height: 16),
            buildStyledNameText(context),
            SizedBox(height: 16),
            buildBasicInfoCard(context),
            SizedBox(height: 16),
            CounterCardWidget(
            key: ValueKey(counterValue), // Add this line
            initialValue: counterValue, 
            onSave: _onSave,
          ),
            
          ],
        ),
      ),
    );
  }

Widget buildStyledNameText(BuildContext context) {
  return Column(
    children: [
      Center(
        child: Text(
          widget.supplyItem.name,
          style: TextStyle(
            fontSize: 24, // Adjust the font size as needed
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 1, 57, 103), // Replace with your desired accent color
          ),
        ),
      ),
      SizedBox(height: 8), // Add some space below the text
      Divider(
        color: Color.fromARGB(255, 1, 57, 103), // Use the same accent color
        thickness: 2, // Adjust the thickness as needed
      ),
      SizedBox(height: 8), // Add some space above and below the divider
    ],
  );
}

Widget buildBasicInfoCard(BuildContext context) {
  return Card(
    elevation: 4, // Adjust the elevation as needed
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Adjust the border radius as needed
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Basic Weight:',
                style: TextStyle(
                  fontSize: 16, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.supplyItem.weight} kg',
                style: TextStyle(
                  fontSize: 16, // Adjust the font size as needed
                ),
              ),
            ],
          ),
          SizedBox(height: 8), // Add some space between the basic weight and manufacturer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manufacturer:',
                style: TextStyle(
                  fontSize: 16, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.supplyItem.manufacturer ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16, // Adjust the font size as needed
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
