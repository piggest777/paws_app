import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/services/firebase_service.dart';

class SupplyItemDetailView extends StatefulWidget {
  final PetCareSupply supply;
  final String boxId;

  const SupplyItemDetailView({super.key, required this.supply, required this.boxId});

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
          offset: const Offset(0, 3), // changes position of shadow
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
              const SizedBox(height: 4),
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
              const SizedBox(height: 4),
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

void _requestCustomWeight(PetCareSupply supply, double quantityToAdd) {
  // Show a dialog to input custom weight
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Use a TextEditingController to capture the input weight
      final TextEditingController weightController = TextEditingController();
      return AlertDialog(
        title: const Text('Enter Custom Weight'),
        content: TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              Navigator.of(context).pop();
              double customWeight = double.tryParse(weightController.text.replaceAll(',', '.')) ?? 0.0;
              if (customWeight <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid weight.')),
                );
                return;
              }
              // Proceed with adding the item with the custom weight
              _proceedWithAddition(supply, quantityToAdd, customWeight);
            },
          ),
        ],
      );
    },
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
            border: const OutlineInputBorder(),
            isDense: true, // Reduces padding and height
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          Text('Details', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
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
          Text('Specifications', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

Widget _buildAddToBoxButton() {
  return ElevatedButton(
    onPressed: () => _addItemToBoxAndDecrementCount(widget.supply),
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      minimumSize: const Size(double.infinity, 50), // Widen the button
    ),
    child: const Text('Add to Box'),
  );
}

void _addItemToBoxAndDecrementCount(PetCareSupply supply) {
      double quantityToAdd = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
      if (quantityToAdd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity.')),
      );
      return;
    }

  if (supply.isGeneric) {
    // If the item is generic, show a dialog to input custom weight
    _requestCustomWeightDialog(supply, quantityToAdd);
  } else {
    if (quantityToAdd > supply.count && !supply.isGeneric) {
      _showConfirmationDialog(supply, quantityToAdd);
    } else {
      _proceedWithAddition(supply, quantityToAdd, 0.0);
    }
  }
}

void _requestCustomWeightDialog(PetCareSupply supply, double quantityToAdd) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final TextEditingController customWeightController = TextEditingController();
      return AlertDialog(
        title: const Text('Enter Weight for Generic Item'),
        content: TextField(
          controller: customWeightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'Weight (kg)'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              double customWeight = double.tryParse(customWeightController.text.replaceAll(',', '.')) ?? 0.0;
              if (customWeight <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid weight.')),
                );
                return;
              }
              Navigator.of(context).pop(); // Close the dialog
              _proceedWithAddition(supply, quantityToAdd, customWeight);
            },
          ),
        ],
      );
    },
  );
}

void _showConfirmationDialog(PetCareSupply supply, double quantityToAdd) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Addition'),
        content: const Text('You are adding more items than available in storage. Do you want to proceed?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Proceed'),
            onPressed: () {
              Navigator.of(context).pop();
              _proceedWithAddition(supply, quantityToAdd, 0.0);
            },
          ),
        ],
      );
    },
  );
}

void _proceedWithAddition(PetCareSupply supply, double quantityToAdd, double customWeight) {

  BoxItem boxItem = _prepareBoxForAddition(supply, quantityToAdd, customWeight);

  FirebaseService().addItemToBoxAndDecrementCount(boxItem, supply.id, quantityToAdd)
      .then((_) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${supply.name} added to box successfully')),
        );

        // Wait for the SnackBar to be displayed briefly, then pop the screen
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      })
      .catchError((error) {
        // Handle error case
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item to box: $error')),
        );
      });
}

BoxItem _prepareBoxForAddition(PetCareSupply supply, double quantityToAdd, double customWeight) {
    if  (supply.isGeneric) {
      return BoxItem.fromPetCareSupplyWithCustomWeight(supply, widget.boxId, quantityToAdd, customWeight);
  } else {
    return BoxItem.fromPetCareSupply(supply, widget.boxId, quantityToAdd);
  }
}

}
