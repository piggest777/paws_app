import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/views/storage/add_supply_page.dart';
import 'package:paws_app/src/views/barcode_scanner_page.dart';
import 'package:paws_app/src/views/storage/supply_item_details.dart';
import 'package:paws_app/src/views/view_components/pet_supply_list_item.dart'; // Import the PetCareSupply class

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  // List to store the filtered supplies
  List<PetCareSupply> filteredSupplies = [];

  TextEditingController searchController = TextEditingController();

  bool showSuggestionButton = false;
  String lastScannedData = '';

  // Function to filter supplies by keywords
  void filterSupplies(String keyword) {
    FirebaseFirestore.instance
        .collection('petSupplyType')
        .where('keywords', arrayContains: keyword.toLowerCase())
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      // Clear the existing list
      setState(() {
        filteredSupplies.clear();
      });

      // Add the filtered supplies to the list
      for (var document in querySnapshot.docs) {
        final data = document.data() as Map<String, dynamic>;
        final id = document.id;
        final supply = PetCareSupply.fromMap(data, id);
        setState(() {
          filteredSupplies.add(supply);
        });
      }

      // Check if any results are empty and update the suggestion button visibility
      setState(() {
        showSuggestionButton = filteredSupplies.isEmpty;
      });
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
      filterSupplies(scannedData);
    } else {
      // Handle the case where no data was scanned
    }
  }

    void navigateToSupplyDetail(PetCareSupply supply) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SupplyItemDetailsPage(supplyItem: supply),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: <Widget>[
          // Add a barcode scan button here
          IconButton(
            onPressed: scanBarcode,
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (keyword) {
                // Call filterSupplies function when text changes
                filterSupplies(keyword);
              },
              decoration: InputDecoration(
                hintText: 'Search by name or keyword',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // Clear the search field and results
                    setState(() {
                      searchController.clear();
                      filteredSupplies.clear();
                      showSuggestionButton =
                          false; // Hide the suggestion button
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          if (showSuggestionButton)
            ElevatedButton(
              onPressed: () {
                // Navigate to the Add Pet Supply page with the scanned barcode as a parameter
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddSupplyPage(
                        initialBarcode:
                            lastScannedData), // Pass the scanned barcode
                  ),
                );
              },
              child: Text('Create a new Pet Supply Type $lastScannedData'),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSupplies.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to the supply detail page when tapped
                    navigateToSupplyDetail(filteredSupplies[index]);
                  },
                  child: PetSupplyListItem(supply: filteredSupplies[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
