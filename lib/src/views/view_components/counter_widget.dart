import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';

class CounterCardWidget extends StatefulWidget {
  final double initialValue; // Initial counter value is now a double
  final Function(double)
      onSave; // Callback to save the counter value, now expects a double
  final PetCareSupply supply;

  const CounterCardWidget(
      {super.key,
      required this.initialValue,
      required this.onSave,
      required this.supply});

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
        TextEditingController(text: widget.initialValue.toStringAsFixed(2));
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
    final TextEditingController customWeightController =
        TextEditingController();

    // Function to calculate weight based on quantity, bypass if generic
    void calculateWeightFromQuantity() {
      if (!widget.supply.isGeneric) {
        final quantity = double.tryParse(
                customQuantityController.text.replaceAll(',', '.')) ??
            0.0;
        final weight = quantity * widget.supply.weight;
        customWeightController.text = weight.toStringAsFixed(2);
      }
    }

    // Function to calculate quantity based on weight, bypass if generic
    void calculateQuantityFromWeight() {
      if (!widget.supply.isGeneric) {
        final weight =
            double.tryParse(customWeightController.text.replaceAll(',', '.')) ??
                0.0;
        final quantity = weight / widget.supply.weight;
        customQuantityController.text = quantity.toStringAsFixed(2);
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // Make the modal scrollable
      builder: (BuildContext context) {
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
                  labelText: 'Quantity',
                  hintText: 'Enter quantity',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*[,\.]?\d{0,2}')),
                ],
                onChanged: widget.supply.isGeneric
                    ? null
                    : (_) => calculateWeightFromQuantity(),
              ),
              if (!widget.supply.isGeneric) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: customWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: 'Enter weight',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*[,\.]?\d{0,2}')),
                  ],
                  onChanged: (_) => calculateQuantityFromWeight(),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Parse the input from the customQuantityController
                  final additionalQuantity = double.tryParse(
                          customQuantityController.text.replaceAll(',', '.')) ??
                      0.0;
                  double finalValueToAdd;

                  // For generic items or when quantity is directly inputted, use the additionalQuantity
                  if (widget.supply.isGeneric ||
                      customWeightController.text.isEmpty) {
                    finalValueToAdd = additionalQuantity;
                  } else {
                    // For non-generic items and when weight is inputted, calculate the quantity to add based on the weight
                    final weight = double.tryParse(
                            customWeightController.text.replaceAll(',', '.')) ??
                        0.0;
                    finalValueToAdd = weight / widget.supply.weight;
                  }

                  setState(() {
                    finalValueToAdd = double.parse(finalValueToAdd.toStringAsFixed(2));
                    editedValue +=
                        finalValueToAdd; // Add the finalValueToAdd to the current editedValue
                    _controller.text = editedValue.toStringAsFixed(
                        2); // Update the text controller to reflect the new total
                    isValueChanged =
                        true; // Indicate that a change has occurred
                  });
                  print(editedValue);
                  widget.onSave(editedValue); // Call the onSave callback with the new total value
                  Navigator.of(context).pop(); // Close the modal bottom sheet
                },
                child: const Text('Add'),
              )
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
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly, // Use space evenly for a balanced layout
              children: [
                // Grouping decrement and increment buttons for a compact look
                IconButton(
                  iconSize:
                      30, // Increase the icon size for better accessibility
                  icon: Icon(Icons.remove_circle_outline,
                      color: theme.colorScheme.error),
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
                  icon: Icon(Icons.add_circle_outline,
                      color: theme.colorScheme.primary),
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                ),
              ],
            ),
            const SizedBox(
                height:
                    20), // Providing more space before the custom quantity button
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Center align the custom quantity button
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit,
                      size: 24), // Using an icon alongside text for clarity
                  label: const Text('Custom Quantity',
                      style: TextStyle(fontSize: 16)),
                  onPressed: () => _showCustomFullScreenModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme
                        .primary, // Use a contrasting color for the custom quantity button
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(
                height:
                    10), // Space before the Save button for visual separation
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isValueChanged
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).disabledColor,
                minimumSize: const Size(double.infinity,
                    50), // Make the save button wider and taller
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
