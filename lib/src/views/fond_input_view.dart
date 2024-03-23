import 'package:flutter/material.dart';
import 'package:paws_app/src/services/firebase_service.dart';
import '../models/fond.dart';

class FondInputView extends StatefulWidget {
  @override
  _FondInputViewState createState() => _FondInputViewState();
}

class _FondInputViewState extends State<FondInputView> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  String _name = '';
  String _fondNumber = '';
  bool _isLoading = false; // Track loading state

  void _saveFond() async {
    setState(() => _isLoading = true); // Start loading
    _formKey.currentState!.save();
    Fond newFond = Fond(name: _name, fondNumber: _fondNumber);

    try {
      await _firebaseService.saveFond(newFond);
      // If success:
      Navigator.of(context).pop(); // Navigate back
    } catch (e) {
      // Handle errors if any
      // For example, show a Snackbar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save fond. Please try again.')),
      );
    } finally {
      setState(() => _isLoading = false); // End loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save Fond Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Fond Number'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _fondNumber = value!,
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Save'),
                onPressed: _isLoading ? null : _saveFond,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

