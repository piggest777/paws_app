import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CounterCardWidget extends StatefulWidget {
  final int initialValue; // Initial counter value
  final Function(int) onSave; // Callback to save the counter value

  CounterCardWidget({Key? key, required this.initialValue, required this.onSave}) : super(key: key); 

  @override
  _CounterCardWidgetState createState() => _CounterCardWidgetState();
}

class _CounterCardWidgetState extends State<CounterCardWidget> {
  late int counterValue;
  late TextEditingController _controller;
  bool isValueChanged = false;
  int editedValue = 0; // Added to track edited value

  @override
  void initState() {
    super.initState();
    counterValue = widget.initialValue;
    editedValue = counterValue; // Initialize editedValue
    _controller = TextEditingController(text: counterValue.toString());
  }

  void _incrementCounter() {
    setState(() {
      if (editedValue > 0) {
        editedValue++;
        _controller.text = editedValue.toString(); // Update text field
        isValueChanged = true;
      }
    });
  }

  void _decrementCounter() {
    setState(() {
      editedValue--;
      _controller.text = editedValue.toString(); // Update text field
      isValueChanged = true;
    });
  }

  void _onSavePressed() {
    int newValue = int.tryParse(_controller.text) ?? 0;
    if (newValue != counterValue) {
      setState(() {
        counterValue = newValue;
        isValueChanged = false; // Reset to false after saving
        widget.onSave(counterValue); // Save the updated value
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: _decrementCounter,
                ),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: _controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        isValueChanged = true;
                        editedValue = int.tryParse(value) ?? 0; // Update editedValue
                      });
                    },
                    onEditingComplete: () {
                      _onSavePressed(); // Call _onSavePressed when editing is complete
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _incrementCounter,
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isValueChanged ? _onSavePressed : null,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
