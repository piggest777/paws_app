import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/views/create_indvidual_box.dart';
import 'package:paws_app/src/views/view_components/box_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoxListView extends StatefulWidget {
  const BoxListView({super.key});

  @override
  _BoxListViewState createState() => _BoxListViewState();
}

class _BoxListViewState extends State<BoxListView> {
  BoxStatus? currentFilterStatus;
  bool isPackingMode = true;

    @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

    _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPackingMode = prefs.getBool('isPackingMode') ?? false;
    });
  }

  _savePreferences(bool isPackingMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPackingMode', isPackingMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boxes'),
        actions: [
          if (!isPackingMode) // Disable filter button when packing mode is on
            IconButton(
              icon: Icon(currentFilterStatus != null ? Icons.filter_alt : Icons.filter_list),
              onPressed: () {
                _showFilterOptions(context);
              },
            ),
          IconButton(
            icon: Icon(Symbols.box_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateIndividualBoxPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Packing Mode:',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Switch(
                  value: isPackingMode,
                  onChanged: (bool value) {
                    setState(() {
                      isPackingMode = value;
                      // Disable single status filter when packing mode is on
                      if (isPackingMode) currentFilterStatus = null;
                    });
                    _savePreferences(isPackingMode);
                  },
                ),
              ],
            ),
          ),
          if (currentFilterStatus != null || isPackingMode)
            BoxCountLabel(
              key: ValueKey(currentFilterStatus ?? isPackingMode), // Update key to trigger rebuild
              filterStatus: currentFilterStatus,
              stream: _filteredBoxStream(),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filteredBoxStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var boxes = snapshot.data!.docs.map((doc) => Box.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
                  return ListView.builder(
                    itemCount: boxes.length,
                    itemBuilder: (context, index) => BoxCard(box: boxes[index]),
                  );
                } else if (snapshot.hasError) {
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
          children: BoxStatus.values.map((status) {
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
        );
      },
    );
  }

  Stream<QuerySnapshot> _filteredBoxStream() {
    var collection = FirebaseFirestore.instance.collection('boxes');
      List<BoxStatus> packingStatuses = [BoxStatus.packing, BoxStatus.created, BoxStatus.packed];
    if (isPackingMode) {
      return collection
        .where('status', whereIn: packingStatuses.map(_formatStatus).toList())
        .where('archived', isEqualTo: false)
        .orderBy('boxID', descending: true)
        .snapshots();
    } else if (currentFilterStatus != null) {
      return collection
        .where('status', isEqualTo: _formatStatus(currentFilterStatus!))
        .where('archived', isEqualTo: false)
        .orderBy('boxID', descending: true)
        .snapshots();
    }
    return collection
      .where('archived', isEqualTo: false)
      .orderBy('boxID', descending: true)
      .snapshots();
  }

  String _formatStatus(BoxStatus status) {
    return status.toString().split('.').last.toLowerCase();
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

