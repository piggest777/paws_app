import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paws_app/src/models/box_item.dart';

class BoxItemDetailsModalContent extends StatefulWidget {
  final BoxItem item;
  final Function(double count, double weight, String ukTranslation)
      onSave; // Updated callback to include Ukrainian translation

  const BoxItemDetailsModalContent({
    Key? key,
    required this.item,
    required this.onSave,
  }) : super(key: key);

  @override
  _BoxItemDetailsModalContentState createState() =>
      _BoxItemDetailsModalContentState();
}

class _BoxItemDetailsModalContentState
    extends State<BoxItemDetailsModalContent> {
  late TextEditingController _countController;
  late TextEditingController _weightController;
  late TextEditingController _ukTranslationController;

  final _decimalInputFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}'));


  @override
  void initState() {
    super.initState();
    _countController =
        TextEditingController(text: widget.item.count.toStringAsFixed(2));
    _weightController =
        TextEditingController(text: widget.item.basicWeight.toStringAsFixed(2));
    _ukTranslationController = TextEditingController(
        text: widget.item.ukTranslation ??
            ""); // Initialize with existing translation, if any
  }

  @override
  void dispose() {
    _countController.dispose();
    _weightController.dispose();
    _ukTranslationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Wrap(
        children: [
          Center(child: _buildModalHandle()),
          const SizedBox(height: 8),
          Text(widget.item.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: _countController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Count'),
            inputFormatters: [_decimalInputFormatter], // Add this line
          ),
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            inputFormatters: [_decimalInputFormatter], // And here
          ),
          TextFormField(
            controller: _ukTranslationController,
            decoration: const InputDecoration(
                labelText: 'Custom ukrainian translation'),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDetailRow('Barcode:', widget.item.barcode ?? 'N/A'),
              _buildDetailRow(
                  'Manufacturer:', widget.item.manufacturer ?? 'N/A'),
              _buildDetailRow('For Whom:', widget.item.forWhom ?? 'N/A'),
              _buildDetailRow('Supply Type:', widget.item.supplyType ?? 'N/A'),
              _buildDetailRow('Food Type:', widget.item.foodType ?? 'N/A'),
              _buildDetailRow('Packaging:', widget.item.packaging ?? 'N/A'),
              // Add any other details you wish to display
            ],
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                final double count = double.tryParse(
                        _countController.text.replaceAll(',', '.')) ??
                    widget.item.count;
                final double weight = double.tryParse(
                        _weightController.text.replaceAll(',', '.')) ??
                    widget.item.basicWeight;
                final String ukTranslation = _ukTranslationController.text;
                widget.onSave(count, weight,
                    ukTranslation); // Pass the updated values back
                Navigator.pop(context); // Close the modal
              },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? iconData}) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      margin: const EdgeInsets.only(bottom: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (iconData != null)
            Icon(iconData, color: theme.primaryColor, size: 20.0),
          const SizedBox(width: 8.0),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHandle() {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
