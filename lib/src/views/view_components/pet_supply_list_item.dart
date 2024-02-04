import 'package:flutter/material.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';

class PetSupplyListItem extends StatelessWidget {
  final PetCareSupply supply;

  PetSupplyListItem({required this.supply});

  @override
  Widget build(BuildContext context) {
    double totalWeight = supply.weight * supply.count; // Calculate total weight

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          supply.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Count: ${supply.count}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total: ${totalWeight.toStringAsFixed(2)} kg',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8), // Add some spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Basic: ${supply.weight.toStringAsFixed(2)} kg',
                  style: TextStyle(fontSize: 16),
                ),
                if (supply.manufacturer != null)
                  Text(
                    'Man.: ${supply.manufacturer}',
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            ),
            if (supply.barcode != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Barcode: ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      supply.barcode!,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

