import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/services/firebase_service.dart';
import 'package:paws_app/src/utils/dropdown_list_provider.dart';
import 'package:paws_app/src/views/view_components/custom_dropdown_list.dart';
import 'package:provider/provider.dart';

class EditSupplyPage extends StatefulWidget {
  final PetCareSupply supplyItem;

  const EditSupplyPage({super.key, required this.supplyItem});

  @override
  _EditSupplyPageState createState() => _EditSupplyPageState();
}

class _EditSupplyPageState extends State<EditSupplyPage> {
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController nameController;
  late TextEditingController barcodeController;
  late TextEditingController manufacturerController;
  late TextEditingController weightController;

  late TextEditingController forWhomCustomController;
  late TextEditingController supplyTypeCustomController;
  late TextEditingController foodTypeCustomController;
  late TextEditingController packagingCustomController;

  String? selectedForWhom;
  String? selectedSupplyType;
  String? selectedFoodType;
  String? selectedPackaging;
  bool isGeneric = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.supplyItem.name);
    barcodeController = TextEditingController(text: widget.supplyItem.barcode ?? '');
    manufacturerController = TextEditingController(text: widget.supplyItem.manufacturer ?? '');
    weightController = TextEditingController(text: isGeneric ? '' : widget.supplyItem.weight.toString());
    isGeneric = widget.supplyItem.isGeneric;

    forWhomCustomController = TextEditingController();
    supplyTypeCustomController = TextEditingController();
    foodTypeCustomController = TextEditingController();
    packagingCustomController = TextEditingController();

    selectedForWhom = widget.supplyItem.forWhom;
    selectedSupplyType = widget.supplyItem.supplyType;
    selectedFoodType = widget.supplyItem.foodType;
    selectedPackaging = widget.supplyItem.packaging;
  }

  void _updateSupplyItem() async {
    // Ensure you add a validation check here similar to AddSupplyPage
    if (isGeneric) {
      weightController.text = "0.0"; // Make sure to adjust this based on your model
    }
    
    PetCareSupply updatedItem = PetCareSupply(
      id: widget.supplyItem.id,
      name: nameController.text,
      barcode: barcodeController.text.isNotEmpty ? barcodeController.text : null,
      manufacturer: manufacturerController.text.isNotEmpty ? manufacturerController.text : null,
      weight: double.tryParse(weightController.text) ?? 0.0,
      keywords: widget.supplyItem.keywords,
      count: widget.supplyItem.count,
      forWhom: selectedForWhom,
      supplyType: selectedSupplyType,
      foodType: selectedFoodType,
      packaging: selectedPackaging,
    );
    

    await _firebaseService.updateSupplyItemTypeInFirebase(updatedItem.id, updatedItem.toMap());
    Navigator.of(context).pop(updatedItem); // Indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Supply Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateSupplyItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: barcodeController,
              decoration: const InputDecoration(labelText: 'Barcode (optional)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextFormField(
              controller: manufacturerController,
              decoration: const InputDecoration(labelText: 'Manufacturer (optional)'),
            ),
            TextFormField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !isGeneric,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))],
            ),
            const SizedBox(height: 16),
              buildDropdown(
                items: [
                  'Dogs',
                  'Puppies',
                  'Cats',
                  'Rodents',
                  'Birds',
                  'Common'],
                selectedValue: selectedForWhom,
                onChanged: (value) => setState(() => selectedForWhom = value),
                onAddItem: (newItem) => {/* Handle addition */},
                hint: 'Select or add a pet type',
              ),
              const SizedBox(height: 16),
              buildDropdown(
                items: [
                  'Food',
                  'Snacks',
                  'Medical',
                  'Clothes',
                  'Toys',
                  'Leashes',
                  'Collars',
                  'Underlay',
                  'Pet home',
                  'Care products',
                  'Pet carrier'
                  'Cages',
                  'Common'
                ],
                selectedValue: selectedSupplyType,
                onChanged: (value) {
                  setState(() {
                    selectedSupplyType = value;
                    if (value != 'Food') {
                      selectedFoodType = null; // Reset food type if not 'Food'
                    }
                  });
                },
                onAddItem: (newItem) => {/* Handle addition */},
                hint: 'Select or add a pet supply type',
              ),
              const SizedBox(height: 16),
              buildDropdown(
                items: [
                  'Wet',
                  'Dry'
                  ],
                selectedValue: selectedFoodType,
                onChanged: (value) => setState(() => selectedFoodType = value),
                onAddItem: (newItem) => {/* Handle addition */},
                hint: 'Select or add a food type',
                isFoodType: true, // This dropdown is conditionally displayed
              ),
              const SizedBox(height: 16),
              buildDropdown(
                items: [
                  'Bags',
                  'Jars',
                  'Item',
                  ],
                selectedValue: selectedPackaging,
                onChanged: (value) {
                  setState(() => selectedPackaging = value);
                },
                onAddItem: (newItem) => {/* Handle addition */},
                hint: 'Select or add a package type',
              ),
              SwitchListTile(
              title: const Text("Is Generic"),
              value: isGeneric,
              onChanged: (bool value) {
                setState(() {
                  isGeneric = value;
                  if (isGeneric) {
                    weightController.text = ''; // Clear weight if generic
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

Widget buildDropdown({
  required List<String> items,
  String? selectedValue,
  required Function(String?) onChanged,
  required Function(String) onAddItem,
  required String hint,
  bool isFoodType = false,
}) {
  // Check if selectedValue is not null and not in the list, then add it
  if (selectedValue != null && !items.contains(selectedValue)) {
    items = [...items, selectedValue]; // Create a new list including the selectedValue
  }

  if (isFoodType && selectedSupplyType != 'Food') {
    return const SizedBox.shrink(); // Don't show the dropdown if 'Food' isn't selected
  }

  return ChangeNotifierProvider<DropdownItemsProvider<String>>(
    create: (_) => DropdownItemsProvider<String>(items),
    child: Consumer<DropdownItemsProvider<String>>(
      builder: (context, provider, _) {
        // Ensure the selectedValue is in the provider's list
        if (selectedValue != null && !provider.items.contains(selectedValue)) {
          provider.addItem(selectedValue);
        }

        return CustomDropdown(
          items: provider.items,
          selectedValue: selectedValue ?? provider.items.first,
          onChanged: (String? value) {
            onChanged(value);
            if (value != null && !provider.items.contains(value)) {
              provider.addItem(value); // Ensures new item is added to provider
            }
          },
          onAddItem: (String newItem) {
            provider.addItem(newItem); // This adds the item to the provider's list
            onAddItem(newItem); // Handle any additional logic for adding the item
          },
          hint: hint,
        );
      },
    ),
  );
}


}
