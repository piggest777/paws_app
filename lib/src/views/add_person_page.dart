import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/views/create_request_page.dart';
import '../models/person.dart';

class AddPersonPage extends StatefulWidget {
  const AddPersonPage({super.key});

  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String surname = '';
  String region = '';
  String city = '';
  String novaPostBranch = '';
  String phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Person"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) => name = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Surname'),
                  onChanged: (value) => surname = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a surname' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Region'),
                  onChanged: (value) => region = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a region' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'City'),
                  onChanged: (value) => city = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a city' : null,
                ),
                TextFormField(
                  initialValue: 'НП-', // Prefill with "НП-"
                  decoration:
                      const InputDecoration(labelText: 'Nova Post Branch'),
                  onChanged: (value) => novaPostBranch = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a nova post branch' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  onChanged: (value) => phone = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a phone' : null,
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _addPersonAndProceed(true);
                              }
                            },
                            child: const Text('Add and Create Request'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _addPersonAndProceed(false);
                              }
                            },
                            child: const Text('Just add'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addPersonAndProceed(bool proceedToNextStep) async {
    Person newPerson = Person(
      id: '', // Leave this empty as Firebase will generate it
      name: name,
      surname: surname,
      region: region,
      city: city,
      novaPostBranch: novaPostBranch,
      phone: phone,
    );

    try {
      DocumentReference docRef =
          await _firestore.collection('persons').add(newPerson.toMap());
      String personId = docRef.id;

      // Optionally, update the person with its ID if necessary
      newPerson = Person(
        id: personId,
        name: name,
        surname: surname,
        region: region,
        city: city,
        novaPostBranch: novaPostBranch,
        phone: phone,
      );

      if (proceedToNextStep) {
        // Navigate to the next step
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RequestCreationPage(person: newPerson),
          ),
        );
      } else {
        // Return to the previous screen after adding
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle any errors here
      print(e.toString());
    }
  }
}
