import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/services/firebase_service.dart';
import 'package:paws_app/src/views/individual_box_recipient_selection_page.dart';
import 'package:paws_app/src/views/view_components/person_card.dart';

class CreateIndividualBoxPage extends StatefulWidget {
  const CreateIndividualBoxPage({super.key});

  @override
  _CreateIndividualBoxPageState createState() =>
      _CreateIndividualBoxPageState();
}

class _CreateIndividualBoxPageState extends State<CreateIndividualBoxPage> {
  BoxSize? _selectedSize;
  BoxType? _selectedType;
  Person? _selectedRecipient;
  final fsService = FirebaseService();
  bool _isProxy = false; // Toggle state
  String? _organizationName; // Organization name entered

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double contentWidth = screenWidth > 600 ? 600 : screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Box'),
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _customDropdownButton<BoxSize>(
                    value: _selectedSize,
                    hint: 'Select Size',
                    items: BoxSize.values.map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text(size.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (size) {
                      setState(() => _selectedSize = size);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _customDropdownButton<BoxType>(
                    value: _selectedType,
                    hint: 'Select Type',
                    items: BoxType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (type) {
                      setState(() => _selectedType = type);
                    },
                  ),
                  const SizedBox(height: 24.0),
                  if (_selectedRecipient != null)
                    Container(
                      width: double
                          .infinity, // Make it take as much width as available
                      alignment:
                          Alignment.center, // Align the card in the center
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: 600), // Max width of 600
                        child: PersonCard(person: _selectedRecipient!),
                      ),
                    ),

                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _navigateAndDisplayRecipientSelection,
                    child: const Text('Select Recipient'),
                  ),
                    SwitchListTile(
    title: const Text('Acting as Proxy?'),
    value: _isProxy,
    onChanged: (bool value) {
      setState(() {
        _isProxy = value;
      });
    },
  ),
  if (_isProxy) // Show TextField if acting as proxy
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Organization Name',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _organizationName = value;
        },
      ),
    ),
                  SizedBox(
                      height: 50), // Provides spacing before the bottom button
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 30), // Add some padding especially at the bottom
        child: ElevatedButton(
          onPressed: _saveBox,
          child: const Text('Save'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(
                double.infinity, 48), // Smaller button with specific height
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
          ),
        ),
      ),
    );
  }

  Widget _customDropdownButton<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required String hint,
    required void Function(T? newValue) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300, // Border color
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade700)),
          items: items,
          onChanged: onChanged,
          dropdownColor: Colors.white,
          style: TextStyle(color: Colors.black, fontSize: 16),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  void _navigateAndDisplayRecipientSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipientSelectionPage()),
    );

    if (result != null && result is Person) {
      setState(() {
        _selectedRecipient = result;
      });
    }
  }

  void _saveBox() async {
    if (_selectedRecipient == null || _selectedSize == null || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a recipient, size, and type.')),
      );
      return;
    }

    try {
      int currentCounter = await fsService.getCurrentCounter();
      String boxId = 'BX${currentCounter.toString().padLeft(4, '0')}'; // Format: BX0001

      // Assuming you have all necessary info to create a Box object
      Box newBox = Box(
        id: boxId, 
        boxID: currentCounter,
        requestId: _selectedRecipient!.id,
        isDirectToPerson: true,
        organizationName: _isProxy ? _organizationName : null, // Since we have a direct recipient
        size: _selectedSize!,
        type: _selectedType!,
        status: BoxStatus.created,
        location: BoxLocation.office, 
        comment: '',
        requesterName: '${_selectedRecipient!.name} ${_selectedRecipient!.surname}', // Example requester name
        creationDate: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('boxes').doc(boxId).set(newBox.toMap());
      await fsService.incrementCounter(currentCounter + 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Box created successfully!')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create box: $e')),
      );
    }
  }
}
