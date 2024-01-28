import 'package:cloud_firestore/cloud_firestore.dart';

class BatchDelivery {
  String id;
  DateTime date;
  int day;
  int month;
  int year;
  List<String> boxList;

  BatchDelivery({
    required this.id,
    required this.date,
    required this.day,
    required this.month,
    required this.year,
    required this.boxList,
  });

  // Converts a Firestore document to a BatchDelivery object
  factory BatchDelivery.fromMap(Map<String, dynamic> map, String id) {
    DateTime date = (map['date'] as Timestamp).toDate();

    return BatchDelivery(
      id: id,
      date: date,
      day: date.day,
      month: date.month,
      year: date.year,
      boxList: List<String>.from(map['boxList'] ?? []),
    );
  }

  // Converts this BatchDelivery object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date, // Firestore will automatically convert this to a Timestamp
      'day': date.day,
      'month': date.month,
      'year': date.year,
      'boxList': boxList,
    };
  }
}

