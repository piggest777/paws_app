import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/views/add_supply_page.dart';
import 'package:paws_app/src/views/scan_supply_page.dart';
import 'package:paws_app/src/views/supply_item_details.dart';
import 'package:paws_app/src/views/view_components/pet_supply_list_item.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({Key? key}) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  List<PetCareSupply> supplies = [];
  List<PetCareSupply> displayedSupplies = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSupplies();
  }

  void fetchSupplies() {
    FirebaseFirestore.instance
        .collection('petSupplyType')
        .where('count', isGreaterThan: 0)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      setState(() {
        supplies = querySnapshot.docs
            .map((doc) => PetCareSupply.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        displayedSupplies = List.from(supplies);
      });
    });
  }

  void filterSupplies(String searchText) {
    List<PetCareSupply> results = [];
    if (searchText.isEmpty) {
      results =
          List.from(supplies); // If search text is empty, display all supplies
    } else {
      results = supplies
          .where((supply) =>
              supply.name.toLowerCase().contains(searchText.toLowerCase()) ||
              (supply.barcode != null &&
                  supply.barcode!
                      .toLowerCase()
                      .contains(searchText.toLowerCase())))
          .toList();
    }

    setState(() {
      displayedSupplies = results;
    });
  }

    void clearSearch() {
    setState(() {
      searchController.clear(); // Clear the search text
      displayedSupplies = List.from(supplies); // Reset to full list
    });
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
        title: Text('Storage'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddSupplyPage(),
                ),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ScanBarcodePage(),
            ),
          );
        },
        child: Icon(Icons.qr_code_scanner),
        heroTag: 'scanItemFAB',
        tooltip: 'Scan Barcode',
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or barcode',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: clearSearch,
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: filterSupplies,
            ),
          ),
          Expanded(
            // This Expanded is correctly used
            child: ListView.builder(
              itemCount: displayedSupplies.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => navigateToSupplyDetail(displayedSupplies[index]),
                  child: PetSupplyListItem(supply: displayedSupplies[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
