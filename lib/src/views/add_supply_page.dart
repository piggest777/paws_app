import 'package:flutter/material.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/services/firebase_service.dart';
import 'package:paws_app/src/utils/dropdown_list_provider.dart';
import 'package:paws_app/src/views/barcode_scanner_page.dart';
import 'package:paws_app/src/views/view_components/custom_dropdown_list.dart';
import 'package:provider/provider.dart';

class AddSupplyPage extends StatefulWidget {
  final String? initialBarcode;

  const AddSupplyPage({super.key, this.initialBarcode});

  @override
  _AddSupplyPageState createState() => _AddSupplyPageState();
}

class _AddSupplyPageState extends State<AddSupplyPage> {
  String? scannedBarcode;
  String? selectedForWhom;
  String? selectedSupplyType;
  String? selectedFoodType;
  String? selectedPackaging;
  String? selectedPetCareItemType;
  bool isGeneric = false;

  final FirebaseService _firebaseService = FirebaseService();

  TextEditingController nameController = TextEditingController();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController manufacturerController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the initial barcode value if provided
    if (widget.initialBarcode != null) {
      barcodeController.text = widget.initialBarcode!;
    }
  }

  // Function to generate keywords from name, barcode, and manufacturer
  List<String> generateKeywords(String name, String? barcode) {
    final keywords = <String>{};

    // Add name keywords
    final nameWords = name.split(' ');
    for (var word in nameWords) {
      for (var i = 1; i <= word.length; i++) {
        keywords.add(word.substring(0, i).toLowerCase());
      }
    }

    // Add barcode keywords (if available)
    if (barcode != null) {
      keywords.add(barcode.toLowerCase());
    }

    return keywords.toList();
  }

  // Function to validate the input fields and return an error message if needed
  bool validateForm() {
    final name = nameController.text;
    final barcode = barcodeController.text;
    final weight = weightController.text;

    // Validate name
    if (name.isEmpty) {
      // Show an error message for name
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name'),
        ),
      );
      return false;
    }

    // Validate barcode (if provided)
    if (barcode.isNotEmpty) {
      try {
        int.parse(barcode); // Check if barcode can be parsed as an integer
      } catch (e) {
        // Show an error message for invalid barcode format
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Invalid barcode format. Please enter a valid integer'),
          ),
        );
        return false;
      }
    }

    // Validate weight
    if (weight.isEmpty) {
      // Show an error message for weight
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a weight'),
        ),
      );
      return false;
    }

    final weightValue = parseDouble(weight);

    if (weightValue == null || weightValue < 0) {
      // Show an error message for invalid or non-positive weight
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Invalid weight format. Please enter a valid positive number'),
        ),
      );
      return false;
    }

    return true;
  }

  void scanBarcode() async {
    final scannedData = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerPage(
          onBarcodeScanned: (data) {
            Navigator.of(context)
                .pop(data); // Pass the scanned data back to the calling page
          },
        ),
      ),
    );

    // Handle the scannedData returned from the Barcode Scanner page here
    if (scannedData != null) {
      print(scannedData);
      barcodeController.text = scannedData;
    } else {
      // Handle the case where no data was scanned
    }
  }

  double? parseDouble(String text) {
    final cleanedValue =
        text.replaceAll(',', '.'); // Replace commas with periods
    try {
      return double.parse(cleanedValue);
    } catch (e) {
      return null; // Return null if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Supply Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSupplyItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Barcode (optional)',
                  border: OutlineInputBorder(),
                ),
                controller: barcodeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Check if the barcode can be parsed as a double
                    try {
                      double.parse(value);
                    } catch (e) {
                      return 'Invalid barcode format. Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildDropdown(
                items: [
                  'Dogs',
                  'Puppies',
                  'Cats',
                  'Rodents',
                  'Birds',
                  'Common'
                ],
                selectedValue: selectedForWhom,
                onChanged: (value) => setState(() => selectedForWhom = value),
                onAddItem: (newItem) => {/* Handle addition */},
                hint: 'Select or add a pet type',
              ),
              buildDropdown(
                items: [
                  'Food',
                  'Bowls',
                  'Boxes',
                  'Cages',
                  'Care products',
                  'Clothes',
                  'Collars',
                  'Common',
                  'Leashes',
                  'Medical',
                  'Pet carrier',
                  'Pet home',
                  'Snacks',
                  'Toys',
                  'Underlay'
                ],
                selectedValue: selectedSupplyType,
                onChanged: (value) {
                  setState(() {
                    selectedSupplyType = value;
                    if (value != 'Food') {
                      selectedFoodType = null; // Reset food type if not 'Food'
                    }
                    if (value != 'Pet Care') {
                      selectedPetCareItemType = null;
                    }
                  });
                },
                onAddItem: (newItem) => {/* Handle addition */},
                hint: 'Select or add a pet supply type',
              ),
              buildDropdown(
                items: ['Wet', 'Dry'],
                selectedValue: selectedFoodType,
                onChanged: (value) => setState(() => selectedFoodType = value),
                onAddItem: (newItem) => {/* Handle addition */},
                hint: 'Select or add a food type',
                isFoodType: true, // This dropdown is conditionally displayed
              ),
              buildPetCareDropdown(),
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
                onAddItem: (newItem) => {},
                hint: 'Select or add a package type',
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Manufacturer (optional)',
                  border: OutlineInputBorder(),
                ),
                controller: manufacturerController,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                enabled: !isGeneric, // Decimal keypad
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Check if the weight can be parsed as a double and is positive
                    try {
                      final weight = double.parse(value);
                      if (weight <= 0.0) {
                        return 'Weight must be a positive number';
                      }
                    } catch (e) {
                      return 'Invalid weight format. Please enter a valid number';
                    }
                  } else {
                    // Weight is empty, return an error message
                    return 'Please enter a weight';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Is this a generic item?'),
                value: isGeneric,
                onChanged: (bool value) {
                  setState(() {
                    isGeneric = value;
                    if (isGeneric) {
                      // If item is marked as generic, weight can be set to zero
                      weightController.text = '0';
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scanBarcode();
        },
        tooltip: 'Save',
        child: const Icon(Icons.barcode_reader),
      ),
    );
  }

    void _saveSupplyItem() async {
    final name = nameController.text;
    final barcode = barcodeController.text.isNotEmpty ? barcodeController.text : null;
    final manufacturer = manufacturerController.text.isNotEmpty ? manufacturerController.text : null;
    final weightText = weightController.text;

    // Validate the inputs
    final isValid = validateForm();
    if (isValid) {
      // Generate keywords
      final keywords = generateKeywords(name, barcode);

      // Determine the supply type based on conditions
      String finalSupplyType = selectedSupplyType!;
      if (selectedSupplyType == "Care Products" && selectedPetCareItemType != null) {
        finalSupplyType = selectedPetCareItemType!;
      }

      // Create a new supply item
      final newSupplyItem = PetCareSupply(
          id: '',
          name: name,
          barcode: barcode,
          manufacturer: manufacturer,
          weight: parseDouble(weightText) ?? 0.0,
          keywords: keywords,
          forWhom: selectedForWhom,
          supplyType: finalSupplyType, // Use the determined supply type
          foodType: selectedFoodType,
          packaging: selectedPackaging,
          isGeneric: isGeneric);

      try {
        // Save the new supply item to Firebase
        await _firebaseService.addSupplyItemTypeToFirebase(newSupplyItem);

        // Navigate back to the previous screen
        Navigator.of(context).pop();
      } catch (error) {
        // Handle the error, e.g., display an error message to the user
        print('Error: $error');
      }
    }
  }

  Widget buildPetCareDropdown() {
    // Define the list of pet care items
    List<String> petCareItems = [
      'Shampoo',
      'Brushes',
      'Nail clippers',
    ];

    return buildDropdown(
      items: petCareItems,
      selectedValue: selectedPetCareItemType,
      onChanged: (value) => setState(() => selectedPetCareItemType = value),
      onAddItem: (newItem) => {/* Handle addition */},
      hint: 'Select or add a pet care item type',
    );
  }

  Widget buildDropdown({
    required List<String> items,
    String? selectedValue,
    required Function(String?) onChanged,
    required Function(String) onAddItem,
    required String hint,
    bool isFoodType = false,
    bool isPetCareItemType = false,
  }) {
    if (isFoodType && selectedSupplyType != 'Food') {
      return const SizedBox.shrink(); // Conditional display logic
    }
    if (isPetCareItemType && selectedSupplyType != 'Care products') {
      return const SizedBox.shrink(); // Conditional display logic
    }

    return ChangeNotifierProvider<DropdownItemsProvider<String>>(
      create: (_) => DropdownItemsProvider<String>(items),
      child: Consumer<DropdownItemsProvider<String>>(
        builder: (context, provider, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomDropdown(
                items: provider.items,
                selectedValue: selectedValue,
                onChanged: (String? value) {
                  onChanged(value);
                  if (value != null && !provider.items.contains(value)) {
                    provider.addItem(
                        value); // Ensures new item is added to provider
                  }
                },
                onAddItem: (String newItem) {
                  provider.addItem(
                      newItem); // This adds the item to the provider's list
                  onAddItem(
                      newItem); // Handle any additional logic for adding the item
                },
                hint: hint,
              ),
              SizedBox(height: 16), // Adjust the height as needed for your UI
            ],
          );
        },
      ),
    );
  }
}
