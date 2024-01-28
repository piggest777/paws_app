import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/views/box_detail_page.dart';

class BoxCardDelivery extends StatelessWidget {
  final Box box;

  const BoxCardDelivery({Key? key, required this.box}) : super(key: key);

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
      title: Text(box.requesterName ?? 'Unknown'),
      subtitle: Text('Weight: ${box.weight.toStringAsFixed(2)} kg'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BoxDetailsPage(boxId: box.id),
        ));
      },
    );
  }
}
