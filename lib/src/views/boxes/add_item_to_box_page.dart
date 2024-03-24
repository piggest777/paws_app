import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/services/firebase_service.dart';
import 'package:paws_app/src/views/barcode_scanner_page.dart';
import 'package:paws_app/src/views/boxes/box_item_detatil_view.dart';
import 'package:paws_app/src/views/view_components/boxitem_list_item.dart';

class AddItemsToBoxPage extends StatefulWidget {
  final String boxId;

  const AddItemsToBoxPage({super.key, required this.boxId});

  @override
  _AddItemsToBoxPageState createState() => _AddItemsToBoxPageState();
}

class _AddItemsToBoxPageState extends State<AddItemsToBoxPage> {
  List<PetCareSupply> filteredSupplies = [];
  TextEditingController searchController = TextEditingController();

  String lastScannedData = '';
  String? customTranslation;

  @override
  void initState() {
    super.initState();
    _fetchGenericSupplies(); // Fetch generic supplies initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Items to Box'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              scanBarcode();
            }, // Implement barcode scan logic
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView.builder(
                  itemCount: filteredSupplies.length,
                  itemBuilder: (BuildContext context, int index) {
                    return BoxItemListItem(
                      supply: filteredSupplies[index],
                      onAdd: () => _addItemToBoxAndDecrementCount(
                          filteredSupplies[index], 1.0),
                      onViewDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SupplyItemDetailView(
                              boxId: widget.boxId,
                              supply: filteredSupplies[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _filterSupplies(String keyword) async {
    if (keyword.isEmpty) {
      // If search is cleared, fetch generic supplies again
      _fetchGenericSupplies();
      return;
    }

    // Use existing logic to filter supplies based on the keyword
    final service = FirebaseService();
    try {
      final supplies = await service.fetchSuppliesByKeyword(keyword);
      setState(() {
        filteredSupplies = supplies;
      });
    } catch (error) {
      print('Error filtering supplies: $error');
    }
  }

    void _fetchGenericSupplies() async {
    final service = FirebaseService();
    try {
      final genericSupplies = await service.fetchGenericSupplies();
      setState(() {
        filteredSupplies = genericSupplies;
      });
    } catch (error) {
      print('Error fetching generic supplies: $error');
    }
  }

Future<Map<String, dynamic>?> _requestCustomWeightAndTranslation(String? supplyType) async {
  TextEditingController weightController = TextEditingController();
  TextEditingController translationController = TextEditingController();
  bool isTranslationRequired = supplyType == null || supplyType == "Medical" || supplyType == "Care products";

  // Initializing the error message as null, meaning no error initially.
  String? errorMessage;

  final result = await showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(  // Enables updating the dialog's state.
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Enter Custom Weight and Translation'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weightController,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Weight (kg)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  TextField(
                    controller: translationController,
                    decoration: InputDecoration(
                      hintText: isTranslationRequired ? 'Ukrainian Translation (Required)' : 'Ukrainian Translation (Optional)',
                      labelText: isTranslationRequired ? 'Ukrainian Translation (Required)' : 'Ukrainian Translation (Optional)',
                    ),
                  ),
                  if (errorMessage != null) // Display error message if it's set.
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 14)),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  double weight = double.tryParse(weightController.text.replaceAll(',', '.')) ?? 0.0;
                  weight = weight < 0.01 ? 0.01 : weight;
                  String? translation = translationController.text;

                  if (isTranslationRequired && translation.isEmpty) {
                    // If translation is required but not provided, update the error message and don't close the dialog.
                    setState(() => errorMessage = 'Ukrainian translation is required.');
                  } else {
                    // If all required inputs are provided, close the dialog and return the values.
                    Navigator.of(context).pop({'weight': weight, 'translation': translation});
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );

  // After the dialog is dismissed or closed, check the result.
  if (result == null) {
    return null; // If result is null (dialog was canceled or dismissed), indicate no action should be taken.
  } else {
    return result; // If OK was pressed and the dialog was closed with data, return that data.
  }
}




  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          _filterSupplies(value);
        },
        decoration: InputDecoration(
          hintText: 'Search by name or keyword',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _fetchGenericSupplies(); // Fetch generic supplies again when search is cleared
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _addSupplyItemToBox(PetCareSupply supply) async {
    // Create a BoxItem instance from the PetCareSupply
    BoxItem boxItem = BoxItem(
      id: FirebaseFirestore.instance
          .collection('boxItems')
          .doc()
          .id, // Generate a new document ID
      name: supply.name,
      count: 1.0,
      basicWeight: supply.weight,
      boxId: widget.boxId,
    );

    // Use FirebaseService to add the item to the box
    try {
      await FirebaseService().addItemToBox(boxItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${supply.name} added to box successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding item to box: $error')),
      );
    }
  }

void _addItemToBoxAndDecrementCount(PetCareSupply supply, double quantityToAdd) async {
  // If the item is not generic, check the quantity
  if (!supply.isGeneric && (quantityToAdd <= 0 || quantityToAdd > supply.count)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid quantity.')),
    );
    return;
  }

  // Check if the supply item is generic
  if (supply.isGeneric) {
    // Request custom weight and Ukrainian translation from the user
    Map<String, dynamic>? result = await _requestCustomWeightAndTranslation(supply.supplyType);
    
    // Check if result is not null and customWeight is valid
    if (result != null && result['weight'] != null && result['weight'] > 0) {
      double customWeight = result['weight'];
      String? ukTranslation = result['translation']; // May be null if the user did not enter a translation
      
      // Adjust the box item with the custom weight and optional Ukrainian translation
      customWeight = customWeight < 0.01 ? 0.01 : customWeight;
      BoxItem boxItem = BoxItem.fromPetCareSupplyWithCustomWeight(supply, widget.boxId, quantityToAdd, customWeight, ukTranslation);
      _addBoxItemWithCustomWeight(boxItem, supply.id, quantityToAdd);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid weight entered.')),
      );
      return;
    }
  } else {
    // If not generic, proceed as normal
    BoxItem boxItem = BoxItem.fromPetCareSupply(supply, widget.boxId, quantityToAdd);
    _addBoxItem(boxItem, supply.id, quantityToAdd);
  }
}

void _addBoxItemWithCustomWeight(BoxItem boxItem, String supplyId, double quantityToAdd) {
  // Use this function to add the box item with a custom weight
  FirebaseService().addItemToBoxAndDecrementCount(boxItem, supplyId, quantityToAdd).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${boxItem.name} added to box with custom weight successfully')),
    );
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  });
}

void _addBoxItem(BoxItem boxItem, String supplyId, double quantityToAdd) {
  FirebaseService().addItemToBoxAndDecrementCount(boxItem, supplyId, quantityToAdd).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${boxItem.name} added to box and count updated successfully')),
    );
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  });
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
      searchController.text = scannedData;
      lastScannedData = scannedData;
      _filterSupplies(scannedData);
    } else {
      // Handle the case where no data was scanned
    }
  }
}
