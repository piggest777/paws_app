import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/services/delivery_item_aggregator.dart';
import 'package:paws_app/src/views/barcode_scanner_page.dart';
import 'package:paws_app/src/views/view_components/box_card_delivery.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  void _fetchBoxesForBatch(String batchId) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('boxes')
        .where('batchId', isEqualTo: batchId)
        .get();

    var fetchedBoxes = snapshot.docs
        .map((doc) => Box.fromMap(doc.data(), doc.id))
        .toList();

    setState(() {
      boxes = fetchedBoxes; // Update local state
    });
  }

  @override
  void initState() {
    super.initState();
    _aggregator = DeliveryItemAggregator(firestore: FirebaseFirestore.instance);
    _fetchBoxesForBatch(widget.batchDeliveryId); // Fetch boxes initially
  }

void _handleAggregateItems() async {
  AggregationResult aggregationResult = await _aggregator!.aggregateItems(widget.batchDeliveryId);
  String csvContent = generateCsvContent(aggregationResult);
  File csvFile = await saveCsvFile(csvContent);
  shareCsvFile(csvFile);
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

  rows.add(["", "", "Total Weight", aggregationResult.totalWeight.toStringAsFixed(2)]);

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
    var boxDocRef = FirebaseFirestore.instance.collection('boxes').doc(scannedBoxId);
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
      var newBox = Box.fromMap(boxSnapshot.data() as Map<String, dynamic>, boxSnapshot.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Delivery ${widget.batchDeliveryId}'),
          actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calculate),
            onPressed: _handleAggregateItems,
            tooltip: 'Aggregate Items',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: boxes.length,
        itemBuilder: (context, index) {
          return BoxCardDelivery(box: boxes[index]);
        },
      ),
floatingActionButton: FloatingActionButton(
  onPressed: () async {
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
  },
  tooltip: 'Scan More Boxes',
  child: const Icon(Icons.qr_code_scanner),
),
    );
  }
}

