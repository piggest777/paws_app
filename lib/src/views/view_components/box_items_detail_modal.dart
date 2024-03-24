import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/services/box_item_service.dart';
import 'package:paws_app/src/views/boxes/box_item_modal_details_content.dart';

class BoxItemDetailsModal {
  final BoxItem item;
  final BuildContext context;
  final VoidCallback onUpdate; // Callback to refresh after updates

  BoxItemDetailsModal({required this.context, required this.item, required this.onUpdate});

  void showDetailsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BoxItemDetailsModalContent(
          item: item,
          onSave: (double count, double weight, String ukTranslation) {
            // Here, we assume that BoxItem has a method or mechanism to update itself
            BoxItemService().updateBoxItem(item.copyWith(
              count: count,
              basicWeight: weight,
              ukTranslation: ukTranslation,
            )).then((_) {
              onUpdate(); // Call onUpdate to refresh the parent view
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating item: $error')));
            });
          },
        );
      },
    );
  }
}
