import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart'; // Import your Box model

class CreateBoxPage extends StatefulWidget {
  final String requestId;
  final String requesterName; 

  const CreateBoxPage({super.key, required this.requestId, required this.requesterName});

  @override
  _CreateBoxPageState createState() => _CreateBoxPageState();
}

class _CreateBoxPageState extends State<CreateBoxPage> {
  BoxSize? _selectedSize;
  BoxType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Box'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              DropdownButton<BoxSize>(
                value: _selectedSize,
                hint: const Text('Select Size'),
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
              DropdownButton<BoxType>(
                value: _selectedType,
                hint: const Text('Select Type'),
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
              ElevatedButton(
                onPressed: () => _saveBoxAndNavigateBack(context),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

void _saveBoxAndNavigateBack(BuildContext context) async {
  if (_selectedSize != null && _selectedType != null) {
    int currentCounter = await _getCurrentCounter();
    
    // Create a new box object with the current counter as boxID
    Box newBox = Box(
      id: '', 
      boxID: currentCounter,
      requestId: widget.requestId, 
      size: _selectedSize!,
      type: _selectedType!,
      status: BoxStatus.created,
      location: BoxLocation.office,
      comment: '',
      creationDate: DateTime.now(), // Set the creation date to the current date and time
      requesterName: widget.requesterName, // Use the requester's name passed in the widget
    );

    // Proceed with saving the new box
    await _addBoxToFirebase(newBox, currentCounter);
    Navigator.pop(context);
  } else {
    _showErrorDialog(context, 'Please select both size and type.');
  }
}

Future<int> _getCurrentCounter() async {
  try {
    var counterDoc = await FirebaseFirestore.instance.collection('counters').doc('boxId').get();
    if (counterDoc.exists) {
      return counterDoc.data()?['current'] ?? 1; // Assuming 'current' is the field name
    } else {
      print('Counter document does not exist');
      return 1; // Default starting value
    }
  } catch (e) {
    print('Error fetching counter: $e');
    return 1; // Handle error scenario
  }
}


Future<void> _addBoxToFirebase(Box box, int currentCounter) async {
  var boxesCollection = FirebaseFirestore.instance.collection('boxes');
  
  await boxesCollection.add(box.toMap()).then((boxRef) async {
    // Increment the counter in Firebase
    await FirebaseFirestore.instance.collection('counters').doc('boxId').update({
      'current': currentCounter + 1
    });

    // Update the request's box count for 'created' status
    await _incrementCreatedBoxCountInRequest(box.requestId);
  }).catchError((error) {
    throw Exception('Failed to create box: $error');
  });
}

Future<void> _incrementCreatedBoxCountInRequest(String requestId) async {
  var requestRef = FirebaseFirestore.instance.collection('requests').doc(requestId);
  return FirebaseFirestore.instance.runTransaction((transaction) async {
    var snapshot = await transaction.get(requestRef);

    if (!snapshot.exists) {
      throw Exception('Request does not exist!');
    }

    // Update the box count for the 'created' status
    int currentCount = snapshot.data()?['boxStatusCounts']['created'] ?? 0;
    transaction.update(requestRef, {
      'boxStatusCounts.created': currentCount + 1
    });
  });
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text('Okay'),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}
}
