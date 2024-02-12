import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScannerPage({super.key, required this.onBarcodeScanned});

  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  bool isScanned = false;
  String scannedData = '';

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) async {
      try {
        if (!isScanned) {
          setState(() {
            isScanned = true;
            scannedData = scanData.code ?? '';
          });

          // Call the callback function to pass the scanned data back
          widget.onBarcodeScanned(scannedData);
        }
      } catch (e) {
        // Handle the exception, e.g., print or log it
        print('Exception: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          QRView(
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
          if (isScanned)
            Positioned(
              top: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Text(
                  scannedData,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
