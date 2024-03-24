import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/services/box_item_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:paws_app/src/views/boxes/act_form_page.dart';
import 'package:paws_app/src/views/boxes/add_item_to_box_page.dart';
import 'package:paws_app/src/views/view_components/box_item_card.dart';
import 'package:paws_app/src/views/view_components/box_items_detail_modal.dart';

class BoxItemsPage extends StatefulWidget {
  final String boxId;
  final String? organizationName;
  final Person? person;

  const BoxItemsPage(
      {super.key, required this.boxId, this.organizationName, this.person});

  @override
  _BoxItemsPageState createState() => _BoxItemsPageState();
}

class _BoxItemsPageState extends State<BoxItemsPage> {
  late Stream<List<BoxItem>> _boxItemsStream;
  double _totalWeight = 0.0;
  double _boxWeight = 0.0;

  @override
  void initState() {
    super.initState();
    _boxItemsStream = BoxItemService().fetchBoxItemsAsStream(widget.boxId);
    _fetchBoxWeight();
    _calculateTotalWeight();
  }

  void _fetchBoxWeight() async {
  // Assuming you have a method in BoxItemService to get the box weight
  double weight = await BoxItemService().fetchBoxWeight(widget.boxId);
  setState(() {
    _boxWeight = weight;
  });
}

void _calculateTotalWeight() async {
  final items = await BoxItemService().fetchBoxItems(widget.boxId);
  double itemsTotalWeight =
      items.fold(0.0, (sum, item) => sum + (item.count * item.basicWeight));
  double newTotalWeight = itemsTotalWeight + _boxWeight; // Include box weight in total

  setState(() {
    _totalWeight = newTotalWeight;
  });

  // Update the total weight in Firebase
  await BoxItemService().updateTotalWeight(widget.boxId, newTotalWeight);
}

  @override
  Widget build(BuildContext context) {
    Color weightColor =
        _totalWeight > 25 ? Colors.deepOrangeAccent : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                'Total: ${_totalWeight.toStringAsFixed(2)} kg',
                style: TextStyle(fontSize: 16), // Adjust fontSize as necessary
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_totalWeight > 25)
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.deepOrangeAccent, size: 20),
                  Text(
                    'Limit!',
                    style: TextStyle(
                        color: weightColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddItemsToBoxPage(boxId: widget.boxId),
                fullscreenDialog: true,
              ));
              _calculateTotalWeight();
            },
            icon: Icon(MdiIcons.packageVariantPlus),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBoxWeightStatus(),
          Expanded(
            child: StreamBuilder<List<BoxItem>>(
              stream: _boxItemsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.data?.isEmpty ?? true) {
                  return _buildEmptyContent();
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      BoxItem item = snapshot.data![index];
                      return Dismissible(
                        key: Key(item
                            .id), // Ensure that the Dismissible widget has a unique key
                        direction:
                            DismissDirection.endToStart, // Swipe direction
                        onDismissed: (direction) {
                          // Handle what happens when an item is swiped away
                          BoxItemService().deleteBoxItem(item.id).then((_) {
                            _calculateTotalWeight();
                            // Optionally, show a snackbar or refresh your list
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Item deleted')),
                            );
                            // If you are using a state management solution, trigger a state update here
                          }).catchError((error) {
                            // Handle error
                          });
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: BoxItemCard(
                          item: item,
                          onViewDetails: () =>
                              _showBoxItemDetailsModal(context, item),
                          onDelete: () => _deleteItem(item.id),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // Positions the button at the bottom center
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreatePdfPressed, // Your PDF creation function
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("Create PDF"),
        backgroundColor:
            Theme.of(context).primaryColor, // Use your theme's primary color
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/empty_box.json',
              width: 200, height: 200), // Adjust path as necessary
          const Text('No items in this box', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildBoxWeightStatus() {
    Color statusColor = _boxWeight > 0 ? Colors.green : Colors.red;
    IconData statusIcon = _boxWeight > 0
        ? Icons.check_circle_outline
        : Icons.warning_amber_rounded;
    String statusText =
        _boxWeight > 0 ? 'Box weight set: ' : 'Set box weight: ';

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(statusIcon, color: statusColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "$statusText${_boxWeight.toStringAsFixed(2)} kg",
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: _editBoxWeight, // Call the method to edit box weight
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(30, 30), // Make the button easier to tap
            ),
            child: Row(
              children: [
                Icon(Icons.edit,
                    size: 20, color: Theme.of(context).primaryColor),
                Text("Edit",
                    style: TextStyle(color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBoxItemDetailsModal(BuildContext context, BoxItem item) {
    BoxItemDetailsModal modal = BoxItemDetailsModal(
        context: context,
        item: item,
        onUpdate: () {
          _calculateTotalWeight();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Item updated successfully')));
        });
    modal.showDetailsModal();
  }

void _editBoxWeight() {
  final TextEditingController controller = TextEditingController(text: _boxWeight.toStringAsFixed(2));
  final FocusNode focusNode = FocusNode(); // Create a FocusNode

  // Listen for focus changes
  focusNode.addListener(() {
    if (focusNode.hasFocus) {
      controller.clear(); // Clear the controller when the field gains focus
    }
  });

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Box Weight'),
        content: TextField(
          controller: controller,
          focusNode: focusNode, // Use the focusNode here
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Weight (kg)',
            hintText: 'Enter new weight',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              focusNode.dispose(); // Clean up the focus node
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (focusNode.hasFocus) {
                focusNode.unfocus(); // Remove focus if still focused
              }
              double? newWeight = double.tryParse(controller.text.replaceAll(',', '.'));
              if (newWeight != null) {
                // Save the new weight to Firebase
                await BoxItemService().updateBoxWeight(widget.boxId, newWeight);
                setState(() {
                  _boxWeight = newWeight;
                  _calculateTotalWeight(); // Recalculate total weight including new box weight
                });
                focusNode.dispose(); // Clean up the focus node
                Navigator.pop(context); // Close the dialog
              } else {
                // Optionally, handle invalid input, e.g., show a message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please enter a valid weight.'),
                ));
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}

  void _deleteItem(String itemId) async {
    await BoxItemService().deleteBoxItem(itemId);
    // Optionally, show a message to the user
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Item removed')));
        _calculateTotalWeight();
  }

  Future<void> onCreatePdfPressed() async {
    final items = await BoxItemService().getActItems(widget.boxId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActFormPage(
          person: widget.person,
          organizationName: widget.organizationName,
          items: items,
          boxWeight: _boxWeight, // Ensure ActFormPage accepts this parameter
        ),
      ),
    );
  }
}
