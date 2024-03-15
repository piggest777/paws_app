import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'csv_sharing_interface.dart';

class CsvSharingMobile implements CsvSharing {
  @override
  void shareCsv(String csvContent, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsString(csvContent);
    Share.shareFiles([file.path], text: 'Items Summary');
  }
}
