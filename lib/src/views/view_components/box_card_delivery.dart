import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/views/boxes/box_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoxCardDelivery extends StatelessWidget {
  final Box box;
  final VoidCallback onDelete;

  const BoxCardDelivery({
    super.key,
    required this.box,
    required this.onDelete,
});

  @override
  Widget build(BuildContext context) {
  List<String> names = box.requesterName.split(' ');
  String displayName;
  if (names.length > 1) {
    String lastName = names.removeLast(); // Remove the last name from the list
    displayName = '$lastName ${names.join(' ')}'; // Place the last name in front
  } else {
    displayName = box.requesterName; // Use the original name if it's a single word
  }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Text(
          box.boxID.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      title: Text(displayName),
      subtitle: Text('Weight: ${box.weight.toStringAsFixed(2)} kg'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Important to avoid taking too much space
        children: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            tooltip: 'Remove from Batch',
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BoxDetailsPage(boxId: box.id),
        ));
      },
    );
  }

  Future<void> _removeBatchId(BuildContext context, String boxId) async {
    // Assuming your box documents are stored in a collection named 'boxes'
    // and each box document ID corresponds to box.id
    try {
      await FirebaseFirestore.instance
          .collection('boxes')
          .doc(boxId)
          .update({'batchId': FieldValue.delete()}); // Removes the batchId property
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Box removed from batch successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error removing box from batch: $e')));
    }
  }
}

