import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box_item.dart';

class BoxItemCard extends StatelessWidget {
  final BoxItem item;
  final VoidCallback onViewDetails;

  const BoxItemCard({
    Key? key,
    required this.item,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total weight
    double totalWeight = item.count * item.basicWeight;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.barcode != null) // Display barcode icon and text if barcode is present
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code, color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 4),
                        Text(item.barcode!, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  // Display manufacturer or "N/A" if not present
                  Text(item.manufacturer ?? 'N/A', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Now showing total weight on the left, swapped with the manufacturer
                  Text('Total: ${totalWeight.toStringAsFixed(2)} kg'),
                  // Display count and basic weight
                  Text('${item.count.toStringAsFixed(0)} x ${item.basicWeight.toStringAsFixed(2)} kg', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




