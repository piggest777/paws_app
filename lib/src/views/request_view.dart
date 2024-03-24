import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paws_app/src/services/group_state.dart';
import 'package:paws_app/src/views/barcode_scanner_page.dart';
import 'package:paws_app/src/views/boxes/box_detail_page.dart';
import 'package:paws_app/src/views/boxes/boxes_page.dart';
import 'package:paws_app/src/views/search_person_page.dart';
import 'package:paws_app/src/views/settings/settings_page.dart';
import 'package:paws_app/src/views/view_components/request_card.dart';
import 'package:provider/provider.dart';

import '../models/request.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    GroupExpandedState groupExpandedState =
        Provider.of<GroupExpandedState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => SettingsPage(),
            ));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_module),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const BoxListView(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQRCode,
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('requests')
                .orderBy('timestamp')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(child: Text('Error fetching data'));
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              }

              List<Request> requests = snapshot.data!.docs.map((doc) {
                return Request.fromMap(
                    doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              Map<String, dynamic> groupedRequests =
                  _groupRequestsByDate(requests);

              return ListView.builder(
                itemCount: groupedRequests.keys.length,
                itemBuilder: (context, index) {
                  String date = groupedRequests.keys.elementAt(index);
                  List<Request> dailyRequests =
                      (groupedRequests[date]!['requests'] as List<dynamic>)
                          .cast<Request>();
                  int createdCount = groupedRequests[date][
                      'createdCount']; // Get the count of created boxes for the date

                  bool isGroupExpanded =
                      groupExpandedState.groupExpandedState[date] ?? false;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: const Color.fromARGB(255, 83, 136, 63),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          title: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$date ', // Display date
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const WidgetSpan(
                                  child: Padding(
                                   padding: EdgeInsets.only(left: 8.0, right: 2.0),
                                    child: Icon(Icons.create,
                                        size: 16.0,
                                        color: Colors.white), // Created icon
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '$createdCount', // Display created box count
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(
                            isGroupExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.white,
                          ),
                          onTap: () {
                            groupExpandedState.toggle(date);
                          },
                        ),
                      ),
                      if (isGroupExpanded)
                        Column(
                          children: dailyRequests
                              .map((request) => RequestCard(request: request))
                              .toList(),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding new request
          _addNewRequest(context);
        },
        heroTag: 'requestFAB',
        tooltip: 'Add Request',
        child: const Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 136, 63, 82),
      ),
    );
  }

  Map<String, Map<String, dynamic>> _groupRequestsByDate(
      List<Request> requests) {
    Map<String, Map<String, dynamic>> groupedRequests = {};

    for (var request in requests) {
      String date = _formatDateReadable(request.timestamp);
      if (groupedRequests[date] == null) {
        groupedRequests[date] = {
          'requests': [],
          'createdCount': 0,
        };
      }

      groupedRequests[date]!['requests'].add(request);

      // Add the 'created' box count from the request to the total 'created' count for the date
      int createdCountForRequest = request.boxStatusCounts['created'] ?? 0;
      groupedRequests[date]!['createdCount'] += createdCountForRequest;
    }

    return _sortGroupedRequestsByDate(groupedRequests);
  }

  Map<String, Map<String, dynamic>> _sortGroupedRequestsByDate(
    Map<String, Map<String, dynamic>> groupedRequests) {
  // Convert date strings back to DateTime objects for comparison
  DateFormat dateFormat = DateFormat('MMM d yyyy'); // Adjust format to match your date strings

  // Sort the keys (dates) based on the DateTime comparison
  var sortedKeys = groupedRequests.keys.toList()
    ..sort((a, b) => dateFormat.parse(b).compareTo(dateFormat.parse(a)));

  // Create a new map with sorted keys
  Map<String, Map<String, dynamic>> sortedGroupedRequests = {
    for (var key in sortedKeys) key: groupedRequests[key]!
  };

  return sortedGroupedRequests;
}

  String _formatDateReadable(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    DateTime date = timestamp.toDate();
    return DateFormat('MMM d yyyy').format(date);
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    DateTime date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _addNewRequest(BuildContext context) {
    // Navigate to a new page or show a dialog to add a new request
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SearchPersonPage()),
    );
  }

void _scanQRCode() async {
  // Push the BarcodeScannerPage and handle the scanned barcode through a callback
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => BarcodeScannerPage(
        onBarcodeScanned: (scannedCode) {
          Navigator.of(context).pop(); // Ensure you pop the scanner page
          _validateAndNavigate(scannedCode);
        },
      ),
    ),
  );
}

  void _validateAndNavigate(String boxId) async {
    // Check if a box with the scanned ID exists in Firestore
    var boxSnapshot =
        await FirebaseFirestore.instance.collection('boxes').doc(boxId).get();
    if (boxSnapshot.exists) {
      // If the box exists, navigate to the BoxDetailsPage with the boxId
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BoxDetailsPage(boxId: boxId),
      ));
    } else {
      // Handle the scenario where the box does not exist
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Box not found with ID: $boxId')));
    }
  }
}
