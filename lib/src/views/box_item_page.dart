import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/models/request.dart';
import 'package:paws_app/src/services/box_item_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:paws_app/src/views/act_form_page.dart';
import 'package:paws_app/src/views/add_item_to_box_page.dart';
import 'package:paws_app/src/views/view_components/box_item_card.dart';
import 'package:paws_app/src/views/view_components/box_items_detail_modal.dart';


class BoxItemsPage extends StatefulWidget {
  final String boxId;
  final Request? request;
  final Person? person;

  const BoxItemsPage({super.key, required this.boxId, this.request, this.person});

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
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data?.isEmpty ?? true) {
            return _buildEmptyContent();
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              BoxItem item = snapshot.data![index];
              return BoxItemCard(
                item: item,
                onViewDetails: () {
                  _showBoxItemDetailsModal(context, item);
                },
              );
            },
          );
        },
      ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Positions the button at the bottom center
        floatingActionButton: FloatingActionButton.extended(
        onPressed: onCreatePdfPressed, // Your PDF creation function
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text("Create PDF"),
        backgroundColor: Theme.of(context).primaryColor, // Use your theme's primary color
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
  BoxItemDetailsModal modal = BoxItemDetailsModal(context: context, item: item);
  modal.showDetailsModal();
}

Future<void> onCreatePdfPressed() async {
  final items = await BoxItemService().getActItems(widget.boxId);
    Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ActFormPage(person: widget.person, items: items,),
    ),
  );
}

}
