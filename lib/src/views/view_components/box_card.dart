import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart'; // Import this package for date formatting
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/utils/box_status_util.dart';
import 'package:paws_app/src/views/box_detail_page.dart';

class BoxCard extends StatelessWidget {
  final Box box;

  const BoxCard({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
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
  title: Row(
    children: <Widget>[
      BoxStatusUtil.getIconForStatus(box.status),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          box.requesterName, // Fallback to 'Unknown' if null
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  ),
  subtitle: Text(
    'Created: ${DateFormat('yyyy-MM-dd').format(box.creationDate ?? DateTime.now())}', // Fallback to current date if null
    style: const TextStyle(fontSize: 12),
  ),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BoxDetailsPage(box: box,),
    ));
  },
);

  }

Icon _getIconForStatus(BoxStatus status) {
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

  String _trimEnumName(String enumString) {
    return enumString.split('.').last;
  }
}

