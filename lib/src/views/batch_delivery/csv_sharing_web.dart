import 'dart:html' as html;
import 'csv_sharing_interface.dart';

class CsvSharingWeb implements CsvSharing {
  @override
  void shareCsv(String csvContent, String fileName) {
    final blob = html.Blob([csvContent], 'text/csv', 'utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
