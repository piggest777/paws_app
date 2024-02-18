import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/services/firebase_service.dart';

class SupplyItemDetailView extends StatefulWidget {
  final PetCareSupply supply;
  final String boxId;

  const SupplyItemDetailView({Key? key, required this.supply, required this.boxId}) : super(key: key);

  @override
  _SupplyItemDetailViewState createState() => _SupplyItemDetailViewState();
}

class _SupplyItemDetailViewState extends State<SupplyItemDetailView> {
  late TextEditingController _quantityController;

    @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(); 
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.supply.name),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuantityInput(),
            const SizedBox(height: 20),
            _buildBarcodeAndCount(),
            const SizedBox(height: 20),
            _buildTypeCard(),
            const SizedBox(height: 20),
            _buildWeightAndManufacturerCard(),
            const SizedBox(height: 20),
            _buildAddToBoxButton(),
          ],
        ),
      ),
    ),
  );
}


Widget _buildBarcodeAndCount() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.blueGrey[50],
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 4,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Barcode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                widget.supply.barcode ?? 'N/A',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey[800],
                ),
              ),
            ],
          ),
        ),
        VerticalDivider(
          color: Colors.blueGrey[300],
          thickness: 1,
          indent: 4,
          endIndent: 4,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${widget.supply.count} units',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _buildQuantityInput() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 200, // Limiting the width for better UX
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: _quantityController,
          decoration: InputDecoration(
            labelText: 'Quantity',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _quantityController.clear,
            ),
            border: OutlineInputBorder(),
            isDense: true, // Reduces padding and height
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ),
    ],
  );
}


Widget _buildTypeCard() {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: Theme.of(context).textTheme.headline6),
          Divider(),
          _buildDetailRow('For Whom:', widget.supply.forWhom ?? 'N/A'),
          _buildDetailRow('Supply Type:', widget.supply.supplyType ?? 'N/A'),
          _buildDetailRow('Food Type:', widget.supply.foodType ?? 'N/A'),
          _buildDetailRow('Packaging:', widget.supply.packaging ?? 'N/A'),
        ],
      ),
    ),
  );
}

Widget _buildWeightAndManufacturerCard() {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specifications', style: Theme.of(context).textTheme.headline6),
          Divider(),
          _buildDetailRow('Weight:', '${widget.supply.weight} kg'),
          _buildDetailRow('Manufacturer:', widget.supply.manufacturer ?? 'N/A'),
        ],
      ),
    ),
  );
}

Widget _buildDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

Widget _buildAddToBoxButton() {
  return ElevatedButton(
    onPressed: () => _addItemToBoxAndDecrementCount(widget.supply),
    child: Text('Add to Box'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      minimumSize: Size(double.infinity, 50), // Widen the button
    ),
  );
}

void _addItemToBoxAndDecrementCount(PetCareSupply supply) {
  String input = _quantityController.text.replaceAll(',', '.');
  double quantityToAdd = double.tryParse(input) ?? 0.0;
  if (quantityToAdd <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a valid quantity.')),
    );
    return;
  }

  if (quantityToAdd > supply.count) {
    // Show alert dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Addition'),
          content: Text('You are adding more items than available in storage. Do you want to proceed?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Proceed'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _proceedWithAddition(supply, quantityToAdd);
              },
            ),
          ],
        );
      },
    );
  } else {
    _proceedWithAddition(supply, quantityToAdd);
  }
}

void _proceedWithAddition(PetCareSupply supply, double quantityToAdd) {
  BoxItem boxItem = BoxItem.fromPetCareSupply(supply, widget.boxId, quantityToAdd);

  FirebaseService().addItemToBoxAndDecrementCount(boxItem, supply.id, quantityToAdd)
      .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${supply.name} added to box and count decremented successfully')),
        );
      })
      .catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
}

}
