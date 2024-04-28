// box_status_util.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:material_symbols_icons/symbols.dart';

class BoxStatusUtil {
  static Icon getIconForStatus(BoxStatus status) {
    switch (status) {
      case BoxStatus.created:
        return const Icon(Icons.create, color: Colors.lightBlue);
      case BoxStatus.packing:
        return const Icon(Icons.work, color: Colors.lightGreen);
      case BoxStatus.packed:
        return const Icon(Icons.inventory, color: Colors.amber);
      case BoxStatus.storage:
        return const Icon(Icons.store, color: Colors.deepPurple);
      case BoxStatus.readyForShipment:
        return Icon(Symbols.package, color: Colors.lightGreen.shade900, fill: 1.0,);
      case BoxStatus.sended:
        return const Icon(Icons.local_shipping, color: Colors.teal);
      case BoxStatus.recived:
        return const Icon(Icons.home_filled, color: Colors.brown);
      case BoxStatus.rapported:
        return const Icon(Icons.check_circle, color: Colors.pinkAccent);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  static String trimToLastElement(BoxStatus status) {
    return status.toString().split('.').last;
  }

    static String getDescriptionForStatus(BoxStatus status) {
    switch (status) {
      case BoxStatus.created:
        return "Created";
      case BoxStatus.packing:
        return "Packing";
      case BoxStatus.packed:
        return "Packed";
      case BoxStatus.storage:
        return "In Storage";
      case BoxStatus.readyForShipment:
        return "Ready for shippment";
      case BoxStatus.sended:
        return "Sent";
      case BoxStatus.recived:
        return "Received";
      case BoxStatus.rapported:
        return "Reported";
      default:
        return "Unknown";
    }
  }

   static Future<void> updateBoxCountsInRequestDocument(Box box,
      BoxStatus newStatus, BoxStatus? oldStatus) async {
    if (oldStatus != null && !box.isDirectToPerson) {
      DocumentReference requestDocRef = 
          FirebaseFirestore.instance.collection('requests').doc(box.requestId);

      // Fetch the current box counts from the request document
      var requestSnapshot = await requestDocRef.get();
      var requestData =
          requestSnapshot.data() as Map<String, dynamic>; // Explicit cast
      Map<String, int> boxCounts = requestData.containsKey('boxStatusCounts')
          ? Map<String, int>.from(requestData['boxStatusCounts'])
          : {};

      // Update the count for the old and new status
      String newStatusKey = newStatus.toString().split('.').last;
      String oldStatusKey = oldStatus.toString().split('.').last;

      boxCounts[newStatusKey] = (boxCounts[newStatusKey] ?? 0) + 1;
      boxCounts[oldStatusKey] = (boxCounts[oldStatusKey] ?? 1) - 1;

      // Ensure counts do not go below zero
      boxCounts[oldStatusKey] =
          boxCounts[oldStatusKey]!.isNegative ? 0 : boxCounts[oldStatusKey]!;

      // Write back the updated counts to the request document
      await requestDocRef.update({'boxStatusCounts': boxCounts});
    }
  }
}

