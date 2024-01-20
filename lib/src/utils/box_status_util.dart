// box_status_util.dart
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';

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
}

