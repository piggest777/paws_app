import 'package:flutter/foundation.dart';
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
  late TextEditingController _weightController;
  bool _isUserInput = true; // Flag to prevent infinite loop of updates

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _weightController = TextEditingController();

    // Listener to update weight when quantity changes
    _quantityController.addListener(() {
      if (_isUserInput && !widget.supply.isGeneric) {
        double quantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0;
        _isUserInput = false; // Prevent triggering the weight listener
        _weightController.text = (quantity * widget.supply.weight).toStringAsFixed(2);
        _isUserInput = true;
      }
    });

    // Listener to update quantity when weight changes
    _weightController.addListener(() {
      if (_isUserInput && !widget.supply.isGeneric) {
        double weight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0;
        _isUserInput = false; // Prevent triggering the quantity listener
        _quantityController.text = (weight / widget.supply.weight).toStringAsFixed(2);
        _isUserInput = true;
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _weightController.dispose();
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
            _buildQuantityAndWeightInput(),
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

Widget _buildQuantityInput() {
  // Your existing method for building the quantity input
  return Container(
    width: 200, // Ensure this width is the same for both inputs for consistency
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
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    ),
  );
}

Widget _buildQuantityAndWeightInput() {
  return LayoutBuilder(
    builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 600; 

      Widget quantityInput = _buildInputField(
        controller: _quantityController,
        label: 'Quantity',
      );

      Widget weightInput = _buildInputField(
        controller: _weightController,
        label: 'Weight (kg)',
      );

      // For mobile, we'll center the inputs vertically and remove the "OR" divider
      if (isMobile) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: quantityInput), // Centered horizontally
            const SizedBox(height: 20), // Space between the inputs for better UX
            if (!widget.supply.isGeneric) Center(child: weightInput), // Conditionally add weight input
          ],
        );
      } else {
        // For web/desktop or larger screens, you can keep your previous layout
        // This part can include the "OR" divider or any other layout adjustments needed for larger screens
        Widget orDivider = Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            quantityInput,
            if (!widget.supply.isGeneric) ...[orDivider, weightInput], // Only add "OR" and weightInput for non-generic supplies
          ],
        );
      }
    },
  );
}

Widget _buildInputField({required TextEditingController controller, required String label}) {
  return Container(
    width: 200, // Limit width
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: controller.clear,
        ),
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    ),
  );
}


Widget _buildWeightInput() {
  // Method to build the weight input, similar to _buildQuantityInput
  return Container(
    width: 200, // Matching the width with the quantity input
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: _weightController,
      decoration: InputDecoration(
        labelText: 'Weight (kg)',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _weightController.clear,
        ),
        border: const OutlineInputBorder(),
        isDense: true, // Reduces padding and height
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    ),
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
    _requestCustomDetailsDialog(supply, quantityToAdd);
  } else {
    if (quantityToAdd > supply.count && !supply.isGeneric) {
      _showConfirmationDialog(supply, quantityToAdd);
    } else {
      _proceedWithAddition(supply, quantityToAdd, 0.0);
    }
  }
}



void _requestCustomDetailsDialog(PetCareSupply supply, double quantityToAdd) {
  final TextEditingController customWeightController = TextEditingController();
  final TextEditingController ukTranslationController = TextEditingController();
  final bool isTranslationRequired = supply.supplyType == null || supply.supplyType == "Medical" || supply.supplyType == "Care products";
  // State to manage visibility of the error message
  String? errorMessage;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder( // Use StatefulBuilder to update the dialog's state
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Enter Details for Generic Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: customWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'Weight (kg)'),
                  ),
                  if (isTranslationRequired)
                  TextField(
                    controller: ukTranslationController,
                    decoration: InputDecoration(
                      hintText: isTranslationRequired ? 'Ukrainian Translation (Required)' : 'Ukrainian Translation (Optional)',
                      labelText: isTranslationRequired ? 'Ukrainian Translation (Required)' : 'Ukrainian Translation (Optional)',
                    ),
                  ),
                  // Display error message if applicable
                  if (errorMessage != null) Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                ],
              ),
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
                  customWeight = customWeight < 0.01 ? 0.01 : customWeight;
                  String? ukTranslation = ukTranslationController.text.isNotEmpty ? ukTranslationController.text : null;

                  if (isTranslationRequired && ukTranslation == null) {
                    // Update error message and refresh dialog state
                    setState(() {
                      errorMessage = 'Ukrainian translation is required for this supply type.';
                    });
                    return; // Keep the dialog open
                  }

                  // Clear error message before closing
                  Navigator.of(context).pop(); // Close the dialog
              _proceedWithAddition(supply, quantityToAdd, customWeight, ukTranslation);
                },
              ),
            ],
          );
        },
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

void _proceedWithAddition(PetCareSupply supply, double quantityToAdd, double customWeight, [String? ukTranslation]) {

  BoxItem boxItem = _prepareBoxForAddition(supply, quantityToAdd, customWeight, ukTranslation);

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

BoxItem _prepareBoxForAddition(PetCareSupply supply, double quantityToAdd, double customWeight, String? ukTranslation) {
    if  (supply.isGeneric) {
      return BoxItem.fromPetCareSupplyWithCustomWeight(supply, widget.boxId, quantityToAdd, customWeight, ukTranslation);
  } else {
    return BoxItem.fromPetCareSupply(supply, widget.boxId, quantityToAdd);
  }
}

}
