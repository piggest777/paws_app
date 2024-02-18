import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paws_app/src/models/act_item.dart';
import 'package:paws_app/src/models/box_item.dart';
import 'package:paws_app/src/services/act_pdf_creator.dart';
import 'package:paws_app/src/services/box_item_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:paws_app/src/views/add_item_to_box_page.dart';
import 'package:paws_app/src/views/view_components/box_item_card.dart';
import 'package:paws_app/src/views/view_components/box_items_detail_modal.dart';
import 'package:paws_app/src/views/view_components/pdf_preview.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class BoxItemsPage extends StatefulWidget {
  final String boxId;

  const BoxItemsPage({Key? key, required this.boxId}) : super(key: key);

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
        title: Text('Box Items'),
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
            return Center(child: CircularProgressIndicator());
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
              ;
            },
          );
        },
      ),

      ///uncomment when functionality is ready
      //       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Positions the button at the bottom center
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: onCreatePdfPressed, // Your PDF creation function
      //   icon: Icon(Icons.picture_as_pdf),
      //   label: Text("Create PDF"),
      //   backgroundColor: Theme.of(context).primaryColor, // Use your theme's primary color
      // ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/empty_box.json',
              width: 200, height: 200), // Adjust path as necessary
          Text('No items in this box', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  void _showBoxItemDetailsModal(BuildContext context, BoxItem item) {
  BoxItemDetailsModal modal = BoxItemDetailsModal(context: context, item: item);
  modal.showDetailsModal();
}

Future<void> onCreatePdfPressed() async {
  final List<ActItem> items = getDummyActItems();
  final pdfFile = await ActPdfCreator.createBoxItemsPdf(
    year: '2022',
    organizationName: 'Your Organization Name',
    organizationNumber: '12345678',
    code: 'Some Code',
    date: 'DD.MM.YYYY',
    humanitarianCode: 'Humanitarian Code',
    recipientName: 'Recipient Name',
    postNumber: 'Post Number',
    address: 'Recipient Address',
    phoneNumber: 'Recipient Phone Number',
    items: items,
    // Pass additional data as needed
  );

  // Preview the PDF file
  // await Printing.layoutPdf(
  //   onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes(),
  // );
    Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PdfPreviewPage(pdfFile: pdfFile),
    ),
  );
}

List<ActItem> getDummyActItems() {
  return [
    ActItem(number: 1, description: 'поводки, рукавички', units: 'шт.', packing: 'виріб', quantity: 11, nettoWeight: 0.8),
    ActItem(number: 2, description: 'миски', units: 'шт.', packing: 'виріб', quantity: 4, nettoWeight: 0.3),
    ActItem(number: 3, description: 'їжа для тварин', units: 'кг.', packing: 'банка', quantity: 15, nettoWeight: 6.15),
    ActItem(number: 4, description: 'шампунь для тварин', units: 'шт.', packing: 'виріб', quantity: 4, nettoWeight: 0.35),
    ActItem(number: 5, description: 'сухий корм для тварин', units: 'кг.', packing: 'пакунок', quantity: 6, nettoWeight: 17.6),
    ActItem(number: 6, description: 'снек', units: 'кг.', packing: 'пакунок', quantity: 1, nettoWeight: 0.5),
  ];
}

  
}
