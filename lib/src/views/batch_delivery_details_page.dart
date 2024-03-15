import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/services/delivery_item_aggregator.dart';
import 'package:paws_app/src/views/barcode_scanner_page.dart';
import 'package:paws_app/src/views/csv_sharing_mobile.dart';
import 'package:paws_app/src/views/view_components/box_card_delivery.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'csv_sharing.dart';

import 'csv_sharing.dart'
    if (dart.library.html) 'csv_sharing_web.dart'
    if (dart.library.io) 'csv_sharing_mobile.dart';

class BatchDeliveryDetailsPage extends StatefulWidget {
  final String batchDeliveryId;

  const BatchDeliveryDetailsPage({super.key, required this.batchDeliveryId});

  @override
  State<BatchDeliveryDetailsPage> createState() =>
      _BatchDeliveryDetailsPageState();
}

class _BatchDeliveryDetailsPageState extends State<BatchDeliveryDetailsPage> {
  List<Box> boxes = []; // Local state for the list of boxes
  DeliveryItemAggregator? _aggregator;
  double _totalWeight = 0.0;
  bool _isAggregating = false;


  void _fetchBoxesForBatch(String batchId) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('boxes')
        .where('archived', isEqualTo: false)
        .where('batchId', isEqualTo: batchId)
        .orderBy('boxID')
        .get();

    var fetchedBoxes =
        snapshot.docs.map((doc) => Box.fromMap(doc.data(), doc.id)).toList();

    // Calculate the total weight here
    double totalWeight = fetchedBoxes.fold(
        0.0, (previousValue, box) => previousValue + box.weight);

    setState(() {
      boxes = fetchedBoxes; // Update local state with fetched boxes
      _totalWeight = totalWeight; // Update total weight
    });
  }

  @override
  void initState() {
    super.initState();
    _aggregator = DeliveryItemAggregator(firestore: FirebaseFirestore.instance);
    _fetchBoxesForBatch(widget.batchDeliveryId); // Fetch boxes initially
  }

void _handleAggregateItems() async {
  showLoadingOverlay(context); // Show the loading overlay

  try {
    AggregationResult aggregationResult =
        await _aggregator!.aggregateItems(widget.batchDeliveryId);
    String csvContent = generateCsvContent(aggregationResult);
    File csvFile = await saveCsvFile(csvContent);
    shareCsvFile(csvFile);
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during aggregation: $error')),
    );
  } finally {
    Navigator.of(context).pop(); // Dismiss the loading overlay
  }
}

  String generateCsvContent(AggregationResult aggregationResult) {
    List<List<String>> rows = [
      ["Description", "Quantity", "Units", "Total Weight"]
    ];

    aggregationResult.summary.forEach((description, summary) {
      rows.add([
        description,
        summary.quantity.toString(),
        summary.units,
        summary.totalWeight.toStringAsFixed(2)
      ]);
    });

    rows.add([
      "",
      "",
      "Total Weight",
      aggregationResult.totalWeight.toStringAsFixed(2)
    ]);

    String csvContent = rows.map((row) => row.join(",")).join("\n");
    return csvContent;
  }

  Future<File> saveCsvFile(String content) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/items_summary.csv';
    final file = File(path);
    await file.writeAsString(content);
    return file;
  }

  void onBoxScanned(String scannedBoxId) async {
    // Fetch the box document
    var boxDocRef =
        FirebaseFirestore.instance.collection('boxes').doc(scannedBoxId);
    var boxSnapshot = await boxDocRef.get();

    if (boxSnapshot.exists) {
      // Update the box status and send date
      await boxDocRef.update({
        'status': 'sended',
        'sendingDate': FieldValue.serverTimestamp(),
        'batchId': widget.batchDeliveryId, // Use server timestamp
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Box $scannedBoxId marked as sent')),
      );

      // Add the scanned box to the local list if necessary
      var newBox = Box.fromMap(
          boxSnapshot.data() as Map<String, dynamic>, boxSnapshot.id);
      setState(() {
        boxes.add(newBox); // Update the list and UI
      });
    } else {
      // Handle the case where the box is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Box not found with ID: $scannedBoxId')),
      );
    }
  }

  void shareCsvFile(File csvFile) {
    Share.shareXFiles([XFile(csvFile.path)], text: 'Items Summary');
  }

  void _removeBoxAndUpdateList(String boxId) {
    FirebaseFirestore.instance.collection('boxes').doc(boxId).update(
        {'batchId': FieldValue.delete(), 'status': 'storage'}).then((_) {
      // After successfully updating, refresh the list of boxes
      _fetchBoxesForBatch(widget.batchDeliveryId);
    }).catchError((error) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing box from batch: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Delivery ${widget.batchDeliveryId}'),
actions: <Widget>[
  if (!kIsWeb) // Hide button for web app
    _isAggregating
        ? CircularProgressIndicator( // Show loading indicator
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
        : IconButton(
            icon: Icon(Icons.calculate),
            onPressed: _isAggregating ? null : _handleAggregateItems, // Block button
            tooltip: 'Aggregate Items',
          ),
],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Weight:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_totalWeight.toStringAsFixed(2)} kg',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: boxes.length,
              itemBuilder: (context, index) {
                return BoxCardDelivery(
                  box: boxes[index],
                  onDelete: () => _showDeleteConfirmationDialog(context, index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanAndAddBox(),
        tooltip: 'Scan More Boxes',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

void showLoadingOverlay(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // User must not close the dialog by tapping outside of it
    builder: (BuildContext context) {
      return PopScope(
        canPop: true,
        child: Center(
                  child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange), // Set your desired color here
        ),

        ),
      );
    },
  );
}



  void _scanAndAddBox() async {
    final scannedBoxId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerPage(
          onBarcodeScanned: (String code) {
            Navigator.of(context).pop(code); // Pop with the scanned code
          },
        ),
      ),
    );

    if (scannedBoxId != null && scannedBoxId.isNotEmpty) {
      onBoxScanned(scannedBoxId); // Handle the scanned code
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text(
              "Are you sure you want to remove this box from the batch?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                // Proceed with the deletion
                _removeBoxAndUpdateList(boxes[index].id);
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
