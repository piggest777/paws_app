import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  final File pdfFile;

  const PdfPreviewPage({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: PdfPreview(
        initialPageFormat: PdfPageFormat.a4,
        build: (format) => pdfFile.readAsBytes(),
      ),
    );
  }
}
