import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final Function(String) onAddItem;
  final String hint;

  const CustomDropdown({
    Key? key,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    required this.onAddItem,
    this.hint = '',
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String? _selectedValue;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> dropdownItems = widget.items
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList();

    // Optionally add a "Custom..." option
    dropdownItems.add(DropdownMenuItem(
      value: 'Custom...',
      child: Text('Custom...'),
    ));

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: widget.hint,
        border: OutlineInputBorder(),
      ),
      value: _selectedValue,
      items: dropdownItems,
      onChanged: (String? newValue) {
        if (newValue == 'Custom...') {
          _promptForCustomValue();
        } else {
          setState(() {
            _selectedValue = newValue;
          });
          widget.onChanged(newValue);
        }
      },
      hint: _selectedValue == null ? Text("Choose one...") : null,
    );
  }

  void _promptForCustomValue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Custom Value'),
          content: TextField(
            controller: _customController,
            decoration: InputDecoration(hintText: "Custom Value"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                final customValue = _customController.text;
                if (customValue.isNotEmpty) {
                  setState(() {
                    _selectedValue = customValue;
                    widget.items.add(customValue); // Add custom value to the list
                  });
                  widget.onChanged(customValue);
                  widget.onAddItem(customValue); // Trigger addition in provider or Firebase
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
