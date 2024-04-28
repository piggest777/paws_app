import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/services/box_item_service.dart'; // Adjust the import path according to your project structure

class BoxItemCard extends StatelessWidget {
  final BoxItem item;
  final VoidCallback onViewDetails;
  final VoidCallback onDelete; // Callback for handling deletion

  const BoxItemCard({
    super.key,
    required this.item,
    required this.onViewDetails,
    required this.onDelete, // Initialize this callback
  });

  @override
  Widget build(BuildContext context) {
    double totalWeight = item.count * item.basicWeight;

    String formatNumber(double n) => n.truncateToDouble() == n ? n.toStringAsFixed(0) : n.toStringAsFixed(2);

    // Get the description from BoxItemService
    String description = BoxItemService.getDescription(item);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          InkWell(
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
                  const SizedBox(height: 2),
                  Text(
                    description, // Display the description
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item.barcode != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code, color: Theme.of(context).primaryColor, size: 20),
                            const SizedBox(width: 4),
                            Text(item.barcode!, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      Text(item.manufacturer ?? 'N/A', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: ${totalWeight.toStringAsFixed(2)} kg'),
                      Text('${formatNumber(item.count)} x ${formatNumber(item.basicWeight)} kg', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.blueGrey),
              onPressed: onDelete, // Use the onDelete callback here
            ),
          ),
        ],
      ),
    );
  }
}
