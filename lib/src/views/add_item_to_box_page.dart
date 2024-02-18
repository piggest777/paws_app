import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/services/firebase_service.dart';
import 'package:paws_app/src/views/barcode_scanner_page.dart';
import 'package:paws_app/src/views/box_item_detatil_view.dart';
import 'package:paws_app/src/views/view_components/boxitem_list_item.dart';

class AddItemsToBoxPage extends StatefulWidget {
  final String boxId;

  const AddItemsToBoxPage({Key? key, required this.boxId}) : super(key: key);

  @override
  _AddItemsToBoxPageState createState() => _AddItemsToBoxPageState();
}

class _AddItemsToBoxPageState extends State<AddItemsToBoxPage> {
  List<PetCareSupply> filteredSupplies = [];
  TextEditingController searchController = TextEditingController();

  String lastScannedData = '';

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
                constraints: BoxConstraints(maxWidth: 600),
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

  void _filterSupplies(String keyword) {
    final service = FirebaseService();
    service.fetchSuppliesByKeyword(keyword).then((supplies) {
      setState(() {
        filteredSupplies = supplies;
      });
    }).catchError((error) {
      print('Error filtering supplies: $error');
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          if (value.length >= 2) {
            _filterSupplies(value);
          } else {
            setState(() => filteredSupplies.clear());
          }
        },
        decoration: InputDecoration(
          hintText: 'Search by name or keyword',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() => filteredSupplies.clear());
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

void _addItemToBoxAndDecrementCount(PetCareSupply supply, double quantityToAdd) {
  if (quantityToAdd <= 0 || quantityToAdd > supply.count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid quantity.')),
    );
    return;
  }

  // Create BoxItem instance
  BoxItem boxItem = BoxItem.fromPetCareSupply(supply, widget.boxId, quantityToAdd);

  // Assuming FirebaseService has a method like addItemToBoxAndDecrementCount
  FirebaseService().addItemToBoxAndDecrementCount(boxItem, supply.id, quantityToAdd).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${supply.name} added to box and count updated successfully')),
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
