import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/views/create_indvidual_box.dart';
import 'package:paws_app/src/views/view_components/box_card.dart';

class BoxListView extends StatefulWidget {
  const BoxListView({super.key});

  @override
  _BoxListViewState createState() => _BoxListViewState();
}

class _BoxListViewState extends State<BoxListView> {
  BoxStatus? currentFilterStatus;
  int itemCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boxes'),
        actions: [
          if (currentFilterStatus != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  currentFilterStatus = null;
                });
              },
            ),
          IconButton(
            icon: currentFilterStatus != null
                ? const Icon(Icons.filter_alt)
                : const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
          IconButton(
            icon: Icon(Symbols.box_add),
            onPressed: () {
              // Navigate to the new screen when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CreateIndividualBoxPage()
                        ), // Replace YourNewScreen with the actual class of your new screen
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (currentFilterStatus != null)
            BoxCountLabel(
              key: ValueKey(currentFilterStatus),
              filterStatus: currentFilterStatus,
              stream: _filteredBoxStream(),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filteredBoxStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var boxes = snapshot
                  .data!.docs.map((doc) {
                    return Box.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();

                  return ListView.builder(
                    itemCount: boxes.length,
                    itemBuilder: (context, index) {
                      return BoxCard(box: boxes[index]);
                    },
                  );
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Center(child: Text('Error fetching boxes'));
                } else {
                  return const Center(child: Text('No boxes found'));
                }
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
            }),
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
          .where('archived', isEqualTo: false)
          .orderBy('boxID')
          .snapshots();
    }
    return collection
    .where('archived', isEqualTo: false)
    .orderBy('boxID')
    .snapshots();
  }

  String _formatStatus(BoxStatus status) {
    return status.toString().split('.').last;
  }
}

class BoxCountLabel extends StatefulWidget {
  final BoxStatus? filterStatus;
  final Stream<QuerySnapshot> stream;

  const BoxCountLabel({
    super.key,
    this.filterStatus,
    required this.stream,
  });

  @override
  _BoxCountLabelState createState() => _BoxCountLabelState();
}

class _BoxCountLabelState extends State<BoxCountLabel> {
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    widget.stream.listen((snapshot) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            itemCount = snapshot.docs.length;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        widget.filterStatus != null
            ? 'Showing $itemCount boxes with status: ${_formatStatus(widget.filterStatus!)}'
            : 'Total boxes: $itemCount',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _formatStatus(BoxStatus status) {
    return status.toString().split('.').last;
  }
}
