import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box_item.dart';

class BoxItemCard extends StatelessWidget {
  final BoxItem item;
  final VoidCallback onViewDetails;

  const BoxItemCard({
    super.key,
    required this.item,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total weight
    double totalWeight = item.count * item.basicWeight;

    String formatNumber(double n) {
      return n.truncateToDouble() == n
          ? n.toStringAsFixed(0)
          : n.toStringAsFixed(2);
    }

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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.barcode !=
                      null) // Display barcode icon and text if barcode is present
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code,
                            color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 4),
                        Text(item.barcode!,
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  // Display manufacturer or "N/A" if not present
                  Text(item.manufacturer ?? 'N/A',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Now showing total weight on the left, swapped with the manufacturer
                  Text('Total: ${totalWeight.toStringAsFixed(2)} kg'),
                  // Display count and basic weight
                  Text(
                    '${formatNumber(item.count)} x ${formatNumber(item.basicWeight)} kg',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
