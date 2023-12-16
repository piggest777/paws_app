import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/views/box_detail_page.dart';
import 'package:paws_app/src/views/qr_scan_page.dart';
import 'package:paws_app/src/views/search_person_page.dart';
import 'package:paws_app/src/views/settings_page.dart';
import 'package:paws_app/src/views/view_components/request_card.dart';

import '../models/request.dart';

class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),

                leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => SettingsPage(),
            ));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: _scanQRCode,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          List<Request> requests = snapshot.data!.docs.map((doc) {
            return Request.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return RequestCard(request: requests[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding new request
          _addNewRequest(context);
        },
        child: Icon(Icons.add),
        tooltip: 'Add Request',
      ),
    );
  }

  void _addNewRequest(BuildContext context) {
    // Navigate to a new page or show a dialog to add a new request
     Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SearchPersonPage()),
                );
  }

void _scanQRCode() async {
  String? scannedCode = await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => QRScanPage()),
  );

  if (scannedCode != null) {
    _validateAndNavigate(scannedCode);
  }
}

void _validateAndNavigate(String boxId) async {
  // Check if a box with the scanned ID exists in Firestore
  var boxSnapshot = await FirebaseFirestore.instance.collection('boxes').doc(boxId).get();
  if (boxSnapshot.exists) {
    // If the box exists, navigate to the BoxDetailsPage with the boxId
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BoxDetailsPage(boxId: boxId),
    ));
  } else {
    // Handle the scenario where the box does not exist
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Box not found with ID: $boxId'))
    );
  }
}
}
