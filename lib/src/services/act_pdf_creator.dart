import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paws_app/src/models/act_item.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

class ActPdfCreator {
  static Future<File> createBoxItemsPdf({
    required String? organizationName,
    required String? organizationNumber,
    required String? recipientOrganizationName,
    required String recipientName,
    required String? recipientNumber,
    required String postNumber,
    required String address,
    required String phoneNumber,
    required List<ActItem> items,
  }) async {
    final totalPackages =
        items.fold<double>(0, (sum, item) => sum + item.quantity);
    final totalWeight =
        items.fold<double>(0, (sum, item) => sum + item.nettoWeight);

    final fontData = await rootBundle.load('assets/fonts/Times New Roman.ttf');
    final ttf = pw.Font.ttf(fontData);

    final fontBoldData =
        await rootBundle.load('assets/fonts/Times New Roman Bold.ttf');
    final ttfBold = pw.Font.ttf(fontBoldData);

    final theme = pw.ThemeData.withFont(
      base: ttf,
      bold: ttfBold,
      italic: ttf,
      boldItalic: ttf,
    );

    final pdf = pw.Document(theme: theme);

    // Example content; customize with your actual data
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'АКТ приймання - передачі благодійної допомоги від _____________',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12, // Optional: Adjust the font size as needed
              ),
              textAlign:
                  pw.TextAlign.center, // Ensure text alignment is centered
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Благодійник:\n${organizationName ?? "_______________________________________________________"} ЄДРПОУ ${organizationNumber ?? "________"}\nу співпраці з організацією, «PAWS OF PEACE», Швеція\n',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              pw.RichText(
                text: const pw.TextSpan(
                  style: pw.TextStyle(fontSize: 10),
                  text:
                      'Підстава для видачі благодійної допомоги: таможенна декларація та код вантажу № _______ від ___________ код гум.допомоги в автоматизованій системі - __________________',
                ),
              ),
              pw.SizedBox(height: 20),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Отримувач: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(recipientOrganizationName ?? recipientName,
                      style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('ЄДРПОУ / ІПН: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(recipientNumber ?? '________________',
                      style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              // Assuming there is a specific value for ЄДРПОУ / ІПН, you would include it here as well
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Доставка: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(recipientName,
                      style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Відділення: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(postNumber, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Адреса: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(address, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Телефон: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(phoneNumber, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          _createProductTable(items, context),
          pw.SizedBox(height: 10),
          pw.Paragraph(
              text:
                  'Всього: ${totalPackages.toStringAsFixed(2)} пакунок вагою ${totalWeight.toStringAsFixed(2)} кг',
              style: const pw.TextStyle(fontSize: 12)),
          pw.Paragraph(
              text:
                  'Усі претензії щодо кількості і якості товару розглядаються виключно під час прийому товару. '
                  'Благодійна допомога сформована виключно з допомоги, яка отримана в якості пожертвування від жертводавців та донорів в місті Стокгольм, Швеція. '
                  'Допомога може включати відкриті упаковки, використані речі. Відповідальність за використання несе отримувач.',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 20),
          pw.Paragraph(
            text:
                'Передав _______________ 	                Отримав _______________',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.Paragraph(
            text:
                'Отримувач добровільно надає згоду на здійснення фото, теле, аудіо, відео - спостереження за допомогою технічних засобів під час отримання та використання благодійної допомоги, '
                'а також на обробку і використання матеріалів вищезгаданих засобів спостереження благодійником $organizationName та Бенефіціаром, що здійснює відповідну діяльність що до фіксації, збору, обробки, використання отриманих матеріалів з метою підтверження отримання благодійної допомоги та її цільового використання. '
                'Отримувач поінформований про заборону продажу цієї допомоги, та про наслідки Адміністративного та кримінального покарання за продаж цієї допомоги згідно нової редакції Кримінального кодексу України від 03.03.2022. '
                'Отримувач поінформований про заборону розповсюдження цієї допомоги в межах території станом на 23.02.2022 зони ОРДЛО та АР Крим.',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    final pdfData = await pdf.save();

    if (kIsWeb) {
      // Running on the web
      final blob = html.Blob([pdfData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "$recipientName.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
      return File('');
    } else {
      // Running on mobile (Android or iOS)
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/$recipientName.pdf");
      await file.writeAsBytes(pdfData);
      return file;
    }
  }

  static pw.Widget _createProductTable(
      List<ActItem> items, pw.Context context) {
    final totalWeight =
        items.fold<double>(0, (sum, item) => sum + item.nettoWeight);

    return pw.Table(border: pw.TableBorder.all(), columnWidths: {
      0: const pw.FlexColumnWidth(10), // Auto width
      1: const pw.FlexColumnWidth(90), // Custom width for description
      2: const pw.FixedColumnWidth(50), // Fixed width for units
      3: const pw.FixedColumnWidth(50), // Fixed width for packing
      4: const pw.FixedColumnWidth(45), // Fixed width for quantity
      5: const pw.FixedColumnWidth(70), // Fixed width for netto weight
    }, children: [
      pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildCell('№', context, alignment: pw.Alignment.center),
            _buildCell(
              'Товар/\nProduct description',
              context,
              alignment: pw.Alignment.centerLeft,
            ),
            _buildCell('Одиниці/\nUnits', context,
                alignment: pw.Alignment.center),
            _buildCell('Упаковка/\nPacking', context,
                alignment: pw.Alignment.center),
            _buildCell('Кількість/\nQuantity', context,
                alignment: pw.Alignment.center),
            _buildCell('Загальна вага/\nTotal Netto weight', context,
                alignment: pw.Alignment.centerRight),
          ]),
      ...items.map((item) => pw.TableRow(
            children: [
              _buildCell(item.number.toString(), context,
                  alignment: pw.Alignment.center),
              _buildCell(item.description, context,
                  alignment: pw.Alignment.centerLeft),
              _buildCell(item.units, context, alignment: pw.Alignment.center),
              _buildCell(item.packing, context, alignment: pw.Alignment.center),
              _buildCell(item.quantity.toStringAsFixed(2), context,
                  alignment: pw.Alignment.center),
              _buildCell("${item.nettoWeight.toStringAsFixed(2)} kg", context,
                  alignment: pw.Alignment.centerRight),
            ],
          )),
      pw.TableRow(children: [
        _buildCell('', context),
        _buildCell('Всього/Total:', context,
            alignment: pw.Alignment.centerLeft, isBold: true),
        _buildCell('', context),
        _buildCell('', context),
        _buildCell('', context),
        _buildCell("${totalWeight.toStringAsFixed(2)} kg", context,
            alignment: pw.Alignment.centerRight, isBold: true),
      ])
    ]);
  }

  static pw.Widget _buildCell(String text, pw.Context context,
      {pw.Alignment alignment = pw.Alignment.center, bool isBold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      alignment: alignment,
      child: pw.Text(text,
          style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 9)),
    );
  }
}
