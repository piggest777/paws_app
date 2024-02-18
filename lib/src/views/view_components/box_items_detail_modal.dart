import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:paws_app/src/models/box_item.dart';

class BoxItemDetailsModal {
  final BoxItem item;
  final BuildContext context;

  BoxItemDetailsModal({required this.context, required this.item});

  void showDetailsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalHandle(),
              SizedBox(height: 8),
              Text(item.name, style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              if (item.barcode != null) _buildBarcodeRow(context),
              _buildDetailRow('Count:', item.count.toStringAsFixed(1)),
              _buildDetailRow('Total Weight:', '${(item.count * item.basicWeight).toStringAsFixed(2)} kg'),
              if (item.manufacturer != null) _buildDetailRow('Manufacturer:', item.manufacturer!),
              _buildTypesColumn(context),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildBarcodeRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.qr_code, color: Theme.of(context).primaryColor),
        SizedBox(width: 8),
        Expanded(child: Text(item.barcode!)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text('$label ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

Widget _buildTypesColumn(BuildContext context) {
  ThemeData theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        _buildTypeInfo(context, Icon(MdiIcons.dog), 'For Whom:', item.forWhom ?? 'N/A'),
        _buildTypeInfo(context, Icon(MdiIcons.sort), 'Supply Type:', item.supplyType ?? 'N/A'),
        _buildTypeInfo(context, Icon(MdiIcons.nutrition), 'Food Type:', item.foodType ?? 'N/A'),
        _buildTypeInfo(context, Icon(MdiIcons.package), 'Packaging:', item.packaging ?? 'N/A'),
      ],
    ),
  );
}

Widget _buildTypeInfo(BuildContext context, Icon icon, String title, String info) {
  ThemeData theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        icon,
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: theme.textTheme.bodyText1!.color),
              children: [
                TextSpan(text: '$title ', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: info, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

}
