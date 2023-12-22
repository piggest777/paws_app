import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

void _onQRViewCreated(QRViewController controller) {
  this.controller = controller;
  controller.scannedDataStream.listen((scanData) {
    final code = scanData.code;
    if (code != null && _isValidFirebaseId(code)) {
      controller.pauseCamera();
      if (Navigator.canPop(context)) {
        Navigator.pop(context, code); // Return the scanned code
      } else {
        print('Cannot pop the current route');
      }
    } else {
      print('Scanned code is not a valid Firebase ID');
    }
  });
}

bool _isValidFirebaseId(String id) {
  return id.length == 20;
}


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
