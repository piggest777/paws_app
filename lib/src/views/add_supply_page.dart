import 'package:flutter/material.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/services/firebase_service.dart';
import 'package:paws_app/src/utils/dropdown_list_provider.dart';
import 'package:paws_app/src/views/barcode_scanner_page.dart';
import 'package:paws_app/src/views/view_components/custom_dropdown_list.dart';
import 'package:provider/provider.dart';

class AddSupplyPage extends StatefulWidget {
  final String? initialBarcode;

  AddSupplyPage({this.initialBarcode});

  @override
  _AddSupplyPageState createState() => _AddSupplyPageState();
}

class _AddSupplyPageState extends State<AddSupplyPage> {
  String? scannedBarcode;
  String? selectedForWhom;
  String? selectedSupplyType;
  String? selectedFoodType;
  String? selectedPackaging;

  final FirebaseService _firebaseService = FirebaseService();

  TextEditingController nameController = TextEditingController();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController manufacturerController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController _forWhomCustomController = TextEditingController();
  TextEditingController _supplyTypeCustomController = TextEditingController();
  TextEditingController _foodTypeCustomController = TextEditingController();
  TextEditingController _packagingCustomController = TextEditingController();

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
        SnackBar(
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
          SnackBar(
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
        SnackBar(
          content: Text('Please enter a weight'),
        ),
      );
      return false;
    }

    final weightValue = parseDouble(weight);

    if (weightValue == null || weightValue <= 0) {
      // Show an error message for invalid or non-positive weight
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
        title: Text('Add Supply Item'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              final name = nameController.text;
              final barcode = barcodeController.text.isNotEmpty
                  ? barcodeController.text
                  : null;
              final manufacturer = manufacturerController.text.isNotEmpty
                  ? manufacturerController.text
                  : null;
              final weightText = weightController.text;

              // Validate the inputs
              final isValid = validateForm();
              if (isValid) {
                // Generate keywords
                final keywords = generateKeywords(name, barcode);

                // Create a new supply item
                final newSupplyItem = PetCareSupply(
                    id: '',
                    name: name,
                    barcode: barcode,
                    manufacturer: manufacturer,
                    weight: parseDouble(weightText) ?? 0.0,
                    keywords: keywords,
                    forWhom: selectedForWhom,
                    supplyType: selectedSupplyType,
                    foodType: selectedFoodType,
                    packaging: selectedPackaging);

                try {
                  // Save the new supply item to Firebase
                  await _firebaseService
                      .addSupplyItemTypeToFirebase(newSupplyItem);

                  // Navigate back to the previous screen
                  Navigator.of(context).pop();
                } catch (error) {
                  // Handle the error, e.g., display an error message to the user
                  print('Error: $error');
                }
              }
            },
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
                decoration: InputDecoration(
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
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Barcode (optional)',
                  border: OutlineInputBorder(),
                ),
                controller: barcodeController,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
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
              // SizedBox(height: 16),
// ChangeNotifierProvider(
//   create: (_) => DropdownItemsProvider(['Dogs', 'Puppies', 'Cats', 'Rodents', 'Common']),
//   builder: (context, _) {
//     return CustomDropdown(
//       items: Provider.of<DropdownItemsProvider<String>>(context, listen: true).items,
//       selectedValue: selectedForWhom, // Use the selectedForWhom variable to set the selected value
//       onChanged: (value) {
//         // Update the selectedForWhom variable with the newly selected value
//         setState(() {
//           selectedForWhom = value;
//         });
//         // Optionally, if you're using a provider to manage state globally, update it here as well
//         // context.read<YourGlobalStateProvider>().updateSelectedForWhom(value);
//       },
//       onAddItem: (newItem) {
//         // Add the new item to the provider's list
//         Provider.of<DropdownItemsProvider<String>>(context, listen: false).addItem(newItem);
//         // Update the selectedForWhom variable with the newly added item
//         setState(() {
//           selectedForWhom = newItem;
//         });
//         // Optionally, save the new item or update global state as needed
//         // context.read<YourGlobalStateProvider>().updateSelectedForWhom(newItem);
//       },
//       hint: 'Select or add a pet type',
//     );
//   },
// ),

              // SizedBox(height: 16),
              // ChangeNotifierProvider(
              //   create: (_) => DropdownItemsProvider([
              //     'Food',
              //     'Medical',
              //     'Clothes',
              //     'Toys',
              //     'Leashes',
              //     'Cages',
              //     'Common'
              //   ]),
              //   builder: (context, _) {
              //     return CustomDropdown(
              //       items: Provider.of<DropdownItemsProvider>(context,
              //               listen: true)
              //           .items,
              //       selectedValue: Provider.of<DropdownItemsProvider>(context)
              //           .selectedItem,
              //       onChanged: (value) {
              //         Provider.of<DropdownItemsProvider>(context, listen: false)
              //             .setSelectedItem(value);
              //             selectedSupplyType = value;
              //       },
              //       onAddItem: (newItem) {
              //         Provider.of<DropdownItemsProvider>(context, listen: false)
              //             .addItem(newItem);
              //             selectedSupplyType = newItem;
              //         // Here you can also add the logic to save the new item to Firebase
              //       },
              //       hint: 'Select or add a pet supply type',
              //     );
              //   },
              // ),
              // SizedBox(height: 16),
              // if (selectedSupplyType == 'Food') ...[
              //   ChangeNotifierProvider(
              //     create: (_) => DropdownItemsProvider(['Wet', 'Dry']),
              //     builder: (context, _) {
              //       return CustomDropdown(
              //         items: Provider.of<DropdownItemsProvider>(context,
              //                 listen: true)
              //             .items,
              //         selectedValue: Provider.of<DropdownItemsProvider>(context)
              //             .selectedItem,
              //         onChanged: (value) {
              //           Provider.of<DropdownItemsProvider>(context,
              //                   listen: false)
              //               .setSelectedItem(value);
              //               selectedFoodType = value;
              //         },
              //         onAddItem: (newItem) {
              //           Provider.of<DropdownItemsProvider>(context,
              //                   listen: false)
              //               .addItem(newItem);
              //               selectedFoodType = newItem;
              //           // Here you can also add the logic to save the new item to Firebase
              //         },
              //         hint: 'Select or add a food type',
              //       );
              //     },
              //   ),
              // ],
              // SizedBox(height: 16),
              // ChangeNotifierProvider(
              //   create: (_) => DropdownItemsProvider([
              //     'Bugs',
              //     'Tins',
              //     'Jars',
              //     'Tube',
              //     'None',
              //   ]),
              //   builder: (context, _) {
              //     return CustomDropdown(
              //       items: Provider.of<DropdownItemsProvider>(context,
              //               listen: true)
              //           .items,
              //       selectedValue: Provider.of<DropdownItemsProvider>(context)
              //           .selectedItem,
              //       onChanged: (value) {
              //         Provider.of<DropdownItemsProvider>(context, listen: false)
              //             .setSelectedItem(value);
              //             selectedPackaging = value;
              //       },
              //       onAddItem: (newItem) {
              //         Provider.of<DropdownItemsProvider>(context, listen: false)
              //             .addItem(newItem);
              //             selectedPackaging = newItem;
              //         // Here you can also add the logic to save the new item to Firebase
              //       },
              //       hint: 'Select or add a package type',
              //     );
              //   },
              // ),
              // CustomDropdown<String>(
              //   items: ['Dogs', 'Puppies', 'Cats', 'Rodents', 'Common'],
              //   selectedValue: null,
              //   onChanged: (value) {
              //     selectedForWhom = value;
              //   },
              //   hint: 'For Whom',
              //   allowCustom: true,
              //   customController: _forWhomCustomController,
              // ),

              // SizedBox(height: 20),
              // CustomDropdown<String>(
              //   items: [
              //     'Food',
              //     'Medical',
              //     'Clothes',
              //     'Toys',
              //     'Leashes',
              //     'Cages',
              //     'Common'
              //   ],
              //   selectedValue: selectedSupplyType,
              //   onChanged: (value) {
              //     setState(() {
              //       selectedSupplyType = value;
              //     });
              //   },
              //   hint: 'Supply Type',
              //   allowCustom: true,
              //   customController: _supplyTypeCustomController,
              // ),
              // // Conditionally show the Food Type dropdown
              // if (selectedSupplyType == 'Food') ...[
              //   SizedBox(height: 20),
              //   CustomDropdown<String>(
              //     items: ['Wet', 'Dry'],
              //     selectedValue: selectedFoodType,
              //     onChanged: (value) {
              //       setState(() {
              //         selectedFoodType = value;
              //       });
              //     },
              //     hint: 'Food Type',
              //     allowCustom: true,
              //     customController: _foodTypeCustomController,
              //   ),
              // ],
              // SizedBox(height: 20),
              // CustomDropdown<String>(
              //   items: [
              //     'Bugs','Tins', 'Jars', 'Tube', 'None', // Predefined options
              //   ],
              //   selectedValue: selectedPackaging,
              //   onChanged: (value) {
              //     setState(() {
              //       selectedPackaging = value;
              //     });
              //   },
              //   hint: 'Packaging',
              //   allowCustom: true,
              //   customController: _packagingCustomController,
              // ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Manufacturer (optional)',
                  border: OutlineInputBorder(),
                ),
                controller: manufacturerController,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                controller: weightController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true), // Decimal keypad
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scanBarcode();
        },
        child: Icon(Icons.barcode_reader),
        tooltip: 'Save',
      ),
    );
  }
}
