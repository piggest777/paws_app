import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/services/box_item_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:paws_app/src/views/act_form_page.dart';
import 'package:paws_app/src/views/add_item_to_box_page.dart';
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

  @override
  void initState() {
    super.initState();
    _boxItemsStream = BoxItemService().fetchBoxItemsAsStream(widget.boxId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Box Items'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddItemsToBoxPage(boxId: widget.boxId),
              fullscreenDialog: true,
            )),
            icon: Icon(MdiIcons.packageVariantPlus),
          ),
        ],
      ),
body: StreamBuilder<List<BoxItem>>(
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
            key: Key(item.id), // Ensure that the Dismissible widget has a unique key
            direction: DismissDirection.endToStart, // Swipe direction
            onDismissed: (direction) {
              // Handle what happens when an item is swiped away
              BoxItemService().deleteBoxItem(item.id).then((_) {
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
              onViewDetails: () => _showBoxItemDetailsModal(context, item),
            ),
          );
        },
      );
    }
    // Fallback widget in case none of the conditions are met (unlikely, but good practice)
    return Center(child: Text("Unexpected state"));
  },
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

  void _showBoxItemDetailsModal(BuildContext context, BoxItem item) {
    BoxItemDetailsModal modal =
        BoxItemDetailsModal(context: context, item: item);
    modal.showDetailsModal();
  }

  void _deleteItem(String itemId) async {
  await BoxItemService().deleteBoxItem(itemId);
  // Optionally, show a message to the user
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item removed')));
  // Recalculate and update the box's weight
  await BoxItemService().recalculateAndUpdateBoxWeight(widget.boxId);
}

  Future<void> onCreatePdfPressed() async {
    final items = await BoxItemService().getActItems(widget.boxId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActFormPage(
          person: widget.person,
          organizationName: widget.organizationName,
          items: items,
        ),
      ),
    );
  }
}
