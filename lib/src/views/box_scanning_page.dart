import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class BoxScanningPage extends StatefulWidget {
  final String batchDeliveryId;
  final Function(String) onBoxScanned;

  const BoxScanningPage({
    super.key,
    required this.batchDeliveryId,
    required this.onBoxScanned,
  });

  @override
  State<BoxScanningPage> createState() => _BoxScanningPageState();
}

class _BoxScanningPageState extends State<BoxScanningPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera(); // Pause the camera after a successful scan
      _updateBoxStatus(scanData.code); // Handle the scanned box ID
    });
  }

  Future<void> _updateBoxStatus(String? boxId) async {
    if (boxId == null || boxId.isEmpty) {
    print('Invalid box ID');
    return;
  }

    // Fetch the box document
    var boxDocRef = FirebaseFirestore.instance.collection('boxes').doc(boxId);
    var boxSnapshot = await boxDocRef.get();

    if (boxSnapshot.exists) {
      // Update the box status and send date
      await boxDocRef.update({
        'status': 'sended',
        'sendingDate': FieldValue.serverTimestamp(), 
        'batchId' : widget.batchDeliveryId
        // Use server timestamp
      });
      // Optional: Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Box $boxId marked as sent')),
      );

        if (mounted) {
    widget.onBoxScanned(boxId); // Call the callback only if the widget is mounted
  } // Corrected line

      Navigator.of(context).pop();
    } else {
      // Optional: Handle the case where the box is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Box not found with ID: $boxId')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Boxes for Batch ${widget.batchDeliveryId}'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
