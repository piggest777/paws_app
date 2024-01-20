import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/models/request.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:paws_app/src/models/box.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:qr/qr.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class PDFManager {
  final Box? box;
  final Request? request;
  final Person? person;


  PDFManager({this.box, this.request, this.person});

Future<void> createAndSharePdf() async {
  final pdf = pw.Document();

  // Load assets
  const logoAsset = 'assets/pop_logo.png'; // Path to your logo asset
  final qrData = box?.id ?? 'Unknown'; // Data for the QR code
  final image = await _loadImage(logoAsset); // Load the logo image
  final qrImage = await generateQRCodeImage(qrData); // Generate QR code image
  final imageBytes = await convertImageToBytes(qrImage);
  final qrPdfImage = pw.MemoryImage(imageBytes);

  // Load custom font
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final ttf = pw.Font.ttf(fontData);

  String boxId = box?.boxID.toString() ?? '';
  String createdDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Create PDF page
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Stack(
          children: [
            pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
              if (image != null)
                pw.Container(
                  margin: const pw.EdgeInsets.all(10),
                  child: pw.Image(image, width: 200, height: 200),
                ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Humanitarian aid for animal shelters',
                style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Гуманітарна допомога для притулків для тварин',
                style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 40),
              if (request?.organizationName != null && request!.organizationName!.isNotEmpty)
                pw.Text(
                  '${request!.organizationName}',
                  style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${person?.name ?? ''} ${person?.surname ?? ''}',
                style: pw.TextStyle(font: ttf, fontSize: 18),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${person?.region ?? ''}, ${person?.city ?? ''}',
                style: pw.TextStyle(font: ttf, fontSize: 18),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                person?.novaPostBranch ?? 'N/A',
                style: pw.TextStyle(font: ttf, fontSize: 18),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                person?.phone ?? 'N/A',
                style: pw.TextStyle(font: ttf, fontSize: 18),
              ),
              pw.SizedBox(height: 20),
              pw.Image(qrPdfImage),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Box Type: ${box?.type.toString().split('.').last ?? 'Unknown'}',
                    style: pw.TextStyle(font: ttf, fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.Align(
              alignment: pw.Alignment.bottomRight,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(right: 10, bottom: 10),
                child: pw.Text(
                  'ID: $boxId | Created: $createdDate',
                  style: pw.TextStyle(
                    fontSize: 12,
                    font: ttf,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );


    final pdfData = await pdf.save();

    if (kIsWeb) {
      // Running on the web
      final blob = html.Blob([pdfData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, "_blank"); // Open in new tab or window
      html.Url.revokeObjectUrl(url); // Clean up the object URL
    } else {
      // Running on mobile (Android or iOS)
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/${request?.surname != null && request!.surname.isNotEmpty ? request!.surname + '_' : ''}box_N${box?.boxID ?? 'details'}.pdf");
      await file.writeAsBytes(pdfData);
      Share.shareXFiles([XFile(file.path)], text: 'Box Details PDF');
    }

  // Save and share PDF
  // final output = await getTemporaryDirectory();
  // final file = File("${output.path}/${request?.surname != null && request!.surname.isNotEmpty ? request!.surname + '_' : ''}box_N${box?.boxID ?? 'details'}.pdf");
  // await file.writeAsBytes(await pdf.save());
  // Share.shareXFiles([XFile(file.path)], text: 'Box Details PDF');
}

  Future<pw.ImageProvider?> _loadImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final image = pw.MemoryImage(
        data.buffer.asUint8List(),
      );
      return image;
    } catch (e) {
      print('Error loading image asset: $e');
      return null;
    }
  }

  Future<ui.Image> generateQRCodeImage(String data) async {
    final qrCode = QrCode(4, QrErrorCorrectLevel.L); // Adjust as needed
    qrCode.addData(data);
    final qrImage = QrImage(qrCode);

    const pixelRatio = 3; // Increase for higher resolution
    final imageSize = qrCode.moduleCount * pixelRatio;
    final painter = ui.PictureRecorder();
    final canvas = ui.Canvas(painter);
    final paint = ui.Paint()..color = const ui.Color(0xFF000000); // QR color

    for (int x = 0; x < qrCode.moduleCount; x++) {
      for (int y = 0; y < qrCode.moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          canvas.drawRect(
            ui.Rect.fromLTWH(
                x * pixelRatio.toDouble(),
                y * pixelRatio.toDouble(),
                pixelRatio.toDouble(),
                pixelRatio.toDouble()),
            paint,
          );
        }
      }
    }

    final pic = painter.endRecording();
    return await pic.toImage(imageSize, imageSize);
  }

  Future<Uint8List> getImageBytes(Future<ui.Image> qrCodeImageFuture) async {
    ui.Image image = await qrCodeImageFuture; // Await the Future<Image>
    return await convertImageToBytes(image);
  }

  Future<Uint8List> convertImageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
