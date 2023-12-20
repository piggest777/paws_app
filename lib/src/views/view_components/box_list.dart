import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/request.dart';
import 'package:paws_app/src/views/box_detail_page.dart';

import '../../models/box.dart';

class BoxListWidget extends StatelessWidget {
  final String requestId;
  final Request request;

  const BoxListWidget({super.key, required this.requestId, required this.request});

  Stream<List<Box>> getBoxesStream() {
    return FirebaseFirestore.instance
        .collection('boxes')
        .where('requestId', isEqualTo: requestId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Box.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: StreamBuilder<List<Box>>(
        stream: getBoxesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const ListTile(title: Text('No boxes found for this request.'));
          }
          List<Widget> boxListItems = [];
          for (var i = 0; i < snapshot.data!.length; i++) {
            boxListItems.add(_buildBoxListItem(context, snapshot.data![i]));
            if (i < snapshot.data!.length - 1) {
              // Add divider for all but the last item
              boxListItems.add(_buildDivider());
            }
          }
          return Column(children: boxListItems);
        },
      ),
    );
  }

Widget _buildBoxListItem(BuildContext context, Box box) {
  return ListTile(
    title: Text('Type: ${box.type.toString().split('.').last}'),
    subtitle: Text('Status: ${box.status.toString().split('.').last}'),
    trailing: Row(
      mainAxisSize: MainAxisSize.min, // Important to keep the row size to a minimum
      children: [
        Text(
          'ID: ${box.boxID}', // Displaying the Box ID
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8), // Spacing between the ID and the icon
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


  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 16.0), // Adjust the padding as needed
      child: Divider(),
    );
  }
}
