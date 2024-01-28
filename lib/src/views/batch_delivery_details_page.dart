import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/views/box_scanning_page.dart';
import 'package:paws_app/src/views/view_components/box_card_delivery.dart';

class BatchDeliveryDetailsPage extends StatefulWidget {
  final String batchDeliveryId;

  const BatchDeliveryDetailsPage({Key? key, required this.batchDeliveryId})
      : super(key: key);

  @override
  State<BatchDeliveryDetailsPage> createState() =>
      _BatchDeliveryDetailsPageState();
}

class _BatchDeliveryDetailsPageState extends State<BatchDeliveryDetailsPage> {
  List<Box> boxes = []; // Local state for the list of boxes

  void _fetchBoxesForBatch(String batchId) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('boxes')
        .where('batchId', isEqualTo: batchId)
        .get();

    var fetchedBoxes = snapshot.docs
        .map((doc) => Box.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    setState(() {
      boxes = fetchedBoxes; // Update local state
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBoxesForBatch(widget.batchDeliveryId); // Fetch boxes initially
  }

  void onBoxScanned(String scannedBoxId) async {
    // Add the scanned box to Firestore and the local list
    await FirebaseFirestore.instance
        .collection('batchDeliveries')
        .doc(widget.batchDeliveryId)
        .update({
      'boxList': FieldValue.arrayUnion([scannedBoxId])
    });

    var boxDocRef = FirebaseFirestore.instance.collection('boxes').doc(scannedBoxId);
    var boxSnapshot = await boxDocRef.get();
    if (boxSnapshot.exists) {
      var newBox = Box.fromMap(boxSnapshot.data() as Map<String, dynamic>, boxSnapshot.id);
      setState(() {
        boxes.add(newBox); // Update the list and UI
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Delivery ${widget.batchDeliveryId}'),
      ),
      body: ListView.builder(
        itemCount: boxes.length,
        itemBuilder: (context, index) {
          return BoxCardDelivery(box: boxes[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BoxScanningPage(
            batchDeliveryId: widget.batchDeliveryId,
            onBoxScanned: onBoxScanned,
          ),
        )),
        child: const Icon(Icons.qr_code_scanner),
        tooltip: 'Scan More Boxes',
      ),
    );
  }
}

