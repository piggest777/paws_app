import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CounterCardWidget extends StatefulWidget {
  final double initialValue; // Initial counter value is now a double
  final Function(double)
      onSave; // Callback to save the counter value, now expects a double

  const CounterCardWidget(
      {super.key, required this.initialValue, required this.onSave});

  @override
  _CounterCardWidgetState createState() => _CounterCardWidgetState();
}

class _CounterCardWidgetState extends State<CounterCardWidget> {
  late double counterValue;
  late TextEditingController _controller;
  bool isValueChanged = false;
  double editedValue = 0.0; // Now a double

  @override
  void initState() {
    super.initState();
    counterValue = widget.initialValue;
    editedValue = counterValue; // Initialize editedValue as a double
    _controller =
        TextEditingController(text: widget.initialValue.toStringAsFixed(1));
  }

  void _addFraction(double fraction) {
    setState(() {
      editedValue += fraction;
      _controller.text =
          editedValue.toStringAsFixed(1); // Keep to one decimal place
      isValueChanged = true;
    });
  }

void _incrementCounter() {
  setState(() {
    editedValue += 1.0;
    _controller.text = editedValue.toStringAsFixed(1);
    // Update isValueChanged based on whether editedValue now differs from initialValue
    isValueChanged = editedValue != widget.initialValue;
  });
}

void _decrementCounter() {
  setState(() {
    if (editedValue > 0) {
      editedValue -= 1.0;
      _controller.text = editedValue.toStringAsFixed(1);
      // Update isValueChanged based on whether editedValue now differs from initialValue
      isValueChanged = editedValue != widget.initialValue;
    }
  });
}

void _onSavePressed() {
  double newValue = double.tryParse(_controller.text) ?? 0.0;
  if (newValue != widget.initialValue) {
    setState(() {
      counterValue = newValue;
      // Reset to false since we are saving the current state as the new baseline
      isValueChanged = false;
    });
    widget.onSave(counterValue);
  }
}


  void _showCustomFullScreenModal(BuildContext context) {
    final TextEditingController customQuantityController =
        TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // Make the modal scrollable
      builder: (BuildContext context) {
        // Use MediaQuery to adjust the padding dynamically based on the keyboard
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: customQuantityController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Add',
                  hintText: 'Enter a number',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*[,\.]?\d{0,1}')),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Replace commas with dots and try parsing the string to double
                  final inputString =
                      customQuantityController.text.replaceAll(',', '.');
                  final double additionalValue =
                      double.tryParse(inputString) ?? 0.0;

                  setState(() {
                    editedValue +=
                        additionalValue; // Add the additionalValue to the existing count
                    _controller.text = editedValue
                        .toStringAsFixed(1); // Reflect this in the TextField
                    isValueChanged = true;
                  });
                  widget.onSave(editedValue); // Persist the new total value
                  Navigator.of(context).pop(); // Close the modal
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Card(
    elevation: 4,
    margin: const EdgeInsets.all(12.0),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use space evenly for a balanced layout
            children: [
              // Grouping decrement and increment buttons for a compact look
              IconButton(
                iconSize: 30, // Increase the icon size for better accessibility
                icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
                onPressed: _decrementCounter,
                tooltip: 'Decrement',
              ),
              // Displaying the quantity in a more central and prominent position
              Text(
                _controller.text,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                onPressed: _incrementCounter,
                tooltip: 'Increment',
              ),
            ],
          ),
          const SizedBox(height: 20), // Providing more space before the custom quantity button
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center align the custom quantity button
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 24), // Using an icon alongside text for clarity
                label: const Text('Custom Quantity', style: TextStyle(fontSize: 16)),
                onPressed: () => _showCustomFullScreenModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, // Use a contrasting color for the custom quantity button
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Space before the Save button for visual separation
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isValueChanged ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
              minimumSize: const Size(double.infinity, 50), // Make the save button wider and taller
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: isValueChanged ? _onSavePressed : null,
            child: const Text('Save', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    ),
  );
}

}
