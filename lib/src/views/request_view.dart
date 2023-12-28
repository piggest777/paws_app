import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/views/box_detail_page.dart';
import 'package:paws_app/src/views/boxes_page.dart';
import 'package:paws_app/src/views/qr_scan_page.dart';
import 'package:paws_app/src/views/search_person_page.dart';
import 'package:paws_app/src/views/settings_page.dart';
import 'package:paws_app/src/views/view_components/request_card.dart';

import '../models/request.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, bool> groupExpandedState = {};

  @override
  Widget build(BuildContext context) {
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
                builder: (context) => BoxListView(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQRCode,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore.collection('requests').orderBy('timestamp').snapshots(),
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
            return Request.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          Map<String, List<Request>> groupedRequests =
              _groupRequestsByDate(requests);

          return ListView.builder(
            itemCount: groupedRequests.keys.length,
            itemBuilder: (context, index) {
              String date = groupedRequests.keys.elementAt(index);
              List<Request> dailyRequests = groupedRequests[date]!;

              bool isGroupExpanded = groupExpandedState[date] ?? true;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(
                        date,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(
                        isGroupExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                      onTap: () {
                        setState(() {
                          groupExpandedState[date] = !isGroupExpanded;
                        });
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding new request
          _addNewRequest(context);
        },
        tooltip: 'Add Request',
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, List<Request>> _groupRequestsByDate(List<Request> requests) {
    Map<String, List<Request>> groupedRequests = {};

    for (var request in requests) {
      String date = _formatDate(request.timestamp);
      if (groupedRequests[date] == null) {
        groupedRequests[date] = [];
      }
      groupedRequests[date]!.add(request);
    }

    return groupedRequests;
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
    String? scannedCode = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const QRScanPage()),
    );

    if (scannedCode != null) {
      _validateAndNavigate(scannedCode);
    }
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
