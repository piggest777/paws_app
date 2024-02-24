import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final Function(String) onAddItem;
  final String hint;

  const CustomDropdown({
    super.key,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    required this.onAddItem,
    this.hint = '',
  });

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

    dropdownItems.add(const DropdownMenuItem(
      value: 'Custom...',
      child: Text('Custom...'),
    ));

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: widget.hint,
        border: const OutlineInputBorder(),
        // Add suffix icon only if a value is selected
        suffixIcon: _selectedValue != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _selectedValue = null; // Clear the current value
                  });
                  widget.onChanged(null); // Notify about the change
                },
              )
            : null,
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
      hint: _selectedValue == null ? const Text("Choose one...") : null,
    );
  }

  void _promptForCustomValue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Custom Value'),
          content: TextField(
            controller: _customController,
            decoration: const InputDecoration(hintText: "Custom Value"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                final customValue = _customController.text;
                if (customValue.isNotEmpty) {
                  setState(() {
                    _selectedValue = customValue;
                  });
                  widget.onChanged(customValue);
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
