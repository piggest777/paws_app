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
            ""); 
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModalHandle(),
              SizedBox(height: 8),
              Text(
                widget.item.name,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _textField("Count", _countController, _decimalInputFormatter),
              _textField("Weight (kg)", _weightController, _decimalInputFormatter),
              TextFormField(
                controller: _ukTranslationController,
                decoration: InputDecoration(labelText: 'Custom Ukrainian translation'),
              ),
              ExpansionTile(
                title: Text('Extra Info', style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  _buildDetailRow('Barcode:', widget.item.barcode ?? 'N/A'),
                  _buildDetailRow('Manufacturer:', widget.item.manufacturer ?? 'N/A'),
                  _buildDetailRow('For Whom:', widget.item.forWhom ?? 'N/A'),
                  _buildDetailRow('Supply Type:', widget.item.supplyType ?? 'N/A'),
                  _buildDetailRow('Food Type:', widget.item.foodType ?? 'N/A'),
                  _buildDetailRow('Packaging:', widget.item.packaging ?? 'N/A'),
                ],
              ),
              ElevatedButton(
                onPressed: _handleSave,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

    Widget _detailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDetailRow('Barcode:', widget.item.barcode ?? 'N/A'),
        _buildDetailRow('Manufacturer:', widget.item.manufacturer ?? 'N/A'),
        _buildDetailRow('For Whom:', widget.item.forWhom ?? 'N/A'),
        _buildDetailRow('Supply Type:', widget.item.supplyType ?? 'N/A'),
        _buildDetailRow('Food Type:', widget.item.foodType ?? 'N/A'),
        _buildDetailRow('Packaging:', widget.item.packaging ?? 'N/A'),
      ],
    );
  }

    Widget _textField(String label, TextEditingController controller, TextInputFormatter formatter) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
        inputFormatters: [formatter],
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

    void _handleSave() {
    final double count = double.tryParse(_countController.text.replaceAll(',', '.')) ?? widget.item.count;
    final double weight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? widget.item.basicWeight;
    final String ukTranslation = _ukTranslationController.text;
    widget.onSave(count, weight, ukTranslation);
    Navigator.pop(context);
  }
}
