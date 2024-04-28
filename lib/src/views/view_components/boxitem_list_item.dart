import 'package:flutter/material.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/services/box_item_service.dart';

class BoxItemListItem extends StatelessWidget {
  final PetCareSupply supply;
  final VoidCallback onAdd; // Callback for adding item quickly
  final VoidCallback onViewDetails; // Callback for viewing details

  const BoxItemListItem({
    super.key,
    required this.supply,
    required this.onAdd,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Use a Card for a more elevated and structured look
    return Card(
      elevation: 2, // Adjust elevation as needed
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(supply.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(BoxItemService.getItemTypeTranslation(supply.supplyType, supply.foodType)),
            Text('Count: ${supply.count}, Weight: ${supply.weight} kg'),
            if (supply.barcode != null)
              Text('Barcode: ${supply.barcode}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (supply.manufacturer != null)
              Text('Man.: ${supply.manufacturer}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: _buildTrailingIcons(context),
        onTap: onViewDetails, // Make the whole tile tappable for details
      ),
    );
  }

Widget _buildTrailingIcons(BuildContext context) {
  const Color myColor = Color.fromARGB(255, 83, 136, 63);
  return Wrap(
    spacing: 8, // Reduced space between icons horizontally
    runSpacing: 0, // Reduced space between icons vertically, if they wrap
    children: <Widget>[
      IconButton(
        icon: const Icon(Icons.add_circle_outline, color: myColor),
        onPressed: onAdd,
        padding: EdgeInsets.zero, // Reduce padding to make the layout more compact
        constraints: const BoxConstraints(), // Remove constraints to allow for smaller padding
      ),
      IconButton(
        icon: const Icon(Icons.chevron_right, color: myColor),
        onPressed: onViewDetails,
        padding: EdgeInsets.zero, // Reduce padding to make the layout more compact
        constraints: const BoxConstraints(), // Remove constraints to allow for smaller padding
      ),
    ],
  );
}


}

