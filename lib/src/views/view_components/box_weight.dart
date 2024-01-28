import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters

class WeightInputWidget extends StatefulWidget {
  final double initialWeight;
  final ValueChanged<double> onWeightChanged;

  const WeightInputWidget({
    Key? key,
    this.initialWeight = 0.0,
    required this.onWeightChanged,
  }) : super(key: key);

  @override
  _WeightInputWidgetState createState() => _WeightInputWidgetState();
}

class _WeightInputWidgetState extends State<WeightInputWidget> {
  late TextEditingController _controller;
  late double currentWeight;
  late double previousWeight; // To store the previous weight
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    currentWeight = widget.initialWeight;
    previousWeight = currentWeight; // Initialize previousWeight
    _controller = TextEditingController(text: currentWeight.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final double? weight = double.tryParse(value);
    if (weight != null && weight != currentWeight) {
      setState(() {
        currentWeight = weight;
        hasChanges = true;
      });
    } else {
      setState(() {
        hasChanges = false;
      });
    }
  }

  void _onEditingComplete() {
    // If the user completes editing without saving, revert to the previous state
    if (!hasChanges) {
      setState(() {
        currentWeight = previousWeight;
        _controller.text = previousWeight.toStringAsFixed(2);
      });
    }
  }

  void _saveWeight() {
    if (hasChanges) {
      widget.onWeightChanged(currentWeight);
      setState(() {
        previousWeight = currentWeight; // Update previousWeight on successful save
        hasChanges = false;
      });
      FocusScope.of(context).unfocus(); // Close the keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color myColor = Color.fromARGB(255, 83, 136, 63);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 5),
          const Icon(Icons.monitor_weight, size: 24.0), // Weight icon
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Allow only decimal numbers
              ],
              onChanged: _onChanged,
              textAlign: TextAlign.center, // Align the text to the center
              onTap: () {
                _controller.clear(); // Clear input field when it gains focus
              },
              onEditingComplete: _onEditingComplete, // Handle when editing is complete
            ),
          ),
          const SizedBox(width: 5),
          TextButton(
            onPressed: hasChanges ? _saveWeight : null, // Disable if no changes
            child: const Text('Save'),
            style: TextButton.styleFrom(
              primary: Colors.white, // Text color
              backgroundColor: hasChanges ? myColor : Colors.grey, // Background color changes based on hasChanges
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}