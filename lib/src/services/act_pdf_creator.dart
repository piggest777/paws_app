import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paws_app/src/models/act_item.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ActPdfCreator {
  static Future<File> createBoxItemsPdf({
    required String year,
    required String organizationName,
    required String organizationNumber,
    required String code,
    required String date,
    required String humanitarianCode,
    required String recipientName,
    required String postNumber,
    required String address,
    required String phoneNumber,
    required List<ActItem> items,
    // Additional parameters for table data can be added here
  }) async {
    final fontData = await rootBundle.load('assets/fonts/Times New Roman.ttf');
    final ttf = pw.Font.ttf(fontData);

    final fontBoldData =
        await rootBundle.load('assets/fonts/Times New Roman Bold.ttf');
    final ttfBold = pw.Font.ttf(fontBoldData);

    final theme = pw.ThemeData.withFont(
      base: ttf, // Set Roboto as the base font for normal text
      bold:
          ttfBold, // Optionally, set Roboto as bold if you have a separate bold font file
      italic:
          ttf, // Optionally, set Roboto as italic if you have a separate italic font file
      boldItalic: ttf, // Optionally, set for boldItalic
    );

    final pdf = pw.Document(theme: theme);

    // Example content; customize with your actual data
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'АКТ приймання - передачі благодійної допомоги від $year',
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
                'Благодійник:\n$organizationName ЄДРПОУ $organizationNumber\nу співпраці з організацією, «PAWS OF PEACE», Швеція\n',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              pw.RichText(
                text: pw.TextSpan(
                  style: pw.TextStyle(fontSize: 10),
                  text:
                      'Підстава для видачі благодійної допомоги: таможенна декларація та код вантажу № $code від $date код гум.допомоги в автоматизованій системі - $humanitarianCode',
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
                  pw.Text(recipientName, style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              // Assuming there is a specific value for ЄДРПОУ / ІПН, you would include it here as well
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Доставка: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(recipientName, style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Відділення: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(postNumber, style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Адреса: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(address, style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Телефон: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(phoneNumber, style: pw.TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          _createProductTable(items, context),
          pw.SizedBox(height: 10),
          pw.Paragraph(
              text: 'Всього: 1 пакунок вагою 25,7 кг',
              style: pw.TextStyle(fontSize: 12)),
          pw.Paragraph(
              text:
                  'Усі претензії щодо кількості і якості товару розглядаються виключно під час прийому товару. '
                  'Благодійна допомога сформована виключно з допомоги, яка отримана в якості пожертвування від жертводавців та донорів в місті Стокгольм, Швеція. '
                  'Допомога може включати відкриті упаковки, використані речі. Відповідальність за використання несе отримувач.',
              style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 20),
          pw.Paragraph(
            text:
                'Передав _______________ 	                Отримав _______________',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.Paragraph(
            text:
                'Отримувач добровільно надає згоду на здійснення фото, теле, аудіо, відео - спостереження за допомогою технічних засобів під час отримання та використання благодійної допомоги, '
                'а також на обробку і використання матеріалів вищезгаданих засобів спостереження благодійником $organizationName та Бенефіціаром, що здійснює відповідну діяльність що до фіксації, збору, обробки, використання отриманих матеріалів з метою підтверження отримання благодійної допомоги та її цільового використання. '
                'Отримувач поінформований про заборону продажу цієї допомоги, та про наслідки Адміністративного та кримінального покарання за продаж цієї допомоги згідно нової редакції Кримінального кодексу України від 03.03.2022. '
                'Отримувач поінформований про заборону розповсюдження цієї допомоги в межах території станом на 23.02.2022 зони ОРДЛО та АР Крим.',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    // Save the PDF file and return its path
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Act_$year.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _createProductTable(
      List<ActItem> items, pw.Context context) {
    final totalWeight =
        items.fold<double>(0, (sum, item) => sum + item.nettoWeight);

    return pw.Table(border: pw.TableBorder.all(), columnWidths: {
      0: pw.FlexColumnWidth(10), // Auto width
      1: pw.FlexColumnWidth(90), // Custom width for description
      2: pw.FixedColumnWidth(50), // Fixed width for units
      3: pw.FixedColumnWidth(50), // Fixed width for packing
      4: pw.FixedColumnWidth(40), // Fixed width for quantity
      5: pw.FixedColumnWidth(70), // Fixed width for netto weight
    }, children: [
      pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildCell('№', context, alignment: pw.Alignment.center),
            _buildCell('Товар/Product description', context,
                alignment: pw.Alignment.centerLeft),
            _buildCell('Одиниці/Units', context,
                alignment: pw.Alignment.center),
            _buildCell('Упаковка/Packing', context,
                alignment: pw.Alignment.center),
            _buildCell('Кількість/Quantity', context,
                alignment: pw.Alignment.center),
            _buildCell('Загальна вага/Total Netto weight', context,
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
              _buildCell(item.quantity.toString(), context,
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
      padding: pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      alignment: alignment,
      child: pw.Text(text,
          style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );
  }
}
