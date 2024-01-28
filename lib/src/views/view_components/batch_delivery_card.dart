import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paws_app/src/models/batch_delivery.dart';
import 'package:paws_app/src/views/batch_delivery_details_page.dart';

class BatchDeliveryCard extends StatelessWidget {
  final BatchDelivery delivery;

  const BatchDeliveryCard({Key? key, required this.delivery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(delivery.date);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            delivery.id,
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text('Delivery on $formattedDate'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to BatchDeliveryDetailsPage with the selected batch delivery ID
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BatchDeliveryDetailsPage(batchDeliveryId: delivery.id),
          ));
        },
      ),
    );
  }
}
