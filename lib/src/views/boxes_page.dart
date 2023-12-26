import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/views/view_components/box_card.dart';

class BoxListView extends StatefulWidget {
  @override
  _BoxListViewState createState() => _BoxListViewState();
}

class _BoxListViewState extends State<BoxListView> {
  BoxStatus? currentFilterStatus;
  int itemCount = 0;
  List<Box> boxes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boxes'),
        actions: [
          if (currentFilterStatus != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  currentFilterStatus = null;
                });
              },
            ),
          IconButton(
            icon: currentFilterStatus != null
                ? Icon(Icons.filter_alt)
                : Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (currentFilterStatus != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Showing $itemCount boxes with status: ${_formatStatus(currentFilterStatus!)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filteredBoxStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  boxes = snapshot.data!.docs.map((doc) {
                    return Box.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();

                  _updateItemCount(boxes.length); // Update the item count here
                } else {
                  boxes.clear();
                  _updateItemCount(0); // Reset the item count
                }

                return boxes.isNotEmpty
                    ? ListView.builder(
                        itemCount: boxes.length,
                        itemBuilder: (context, index) {
                          return BoxCard(box: boxes[index]);
                        },
                      )
                    : Center(
                        child: Text(currentFilterStatus != null
                            ? 'No boxes found with status ${_formatStatus(currentFilterStatus!)}'
                            : 'No boxes found'),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: [
            ...BoxStatus.values.map((BoxStatus status) {
              return ListTile(
                title: Text(_formatStatus(status)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentFilterStatus = status;
                  });
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot> _filteredBoxStream() {
    var collection = FirebaseFirestore.instance.collection('boxes');
    if (currentFilterStatus != null) {
      return collection
          .where('status', isEqualTo: _formatStatus(currentFilterStatus!))
          .orderBy('boxID')
          .snapshots();
    }
    return collection.orderBy('boxID').snapshots();
  }

  String _formatStatus(BoxStatus status) {
    return status.toString().split('.').last;
  }

void _updateItemCount(int newCount) {
  Future.microtask(() {
    if (mounted) {
      setState(() {
        itemCount = newCount;
      });
    }
  });
}
}
