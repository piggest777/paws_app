import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BarcodeImageWidget extends StatelessWidget {
  final String barcodeValue;

  BarcodeImageWidget({required this.barcodeValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: QrImageView(
            data: barcodeValue,
            version: QrVersions.auto,
            size: 120,
            gapless: false,
          ),
        ),
         // Add some spacing between the QR code and text
        Text(
          '$barcodeValue',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
