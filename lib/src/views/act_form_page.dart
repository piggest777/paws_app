import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/act_information.dart';
import 'package:paws_app/src/models/act_item.dart';
import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/services/act_pdf_creator.dart';
import 'package:paws_app/src/views/view_components/pdf_preview.dart';
// Define this model based on your needs
// import 'package:paws_app/src/utils/pdf_generator.dart'; // Assume this utility class exists for PDF generation

class ActFormPage extends StatefulWidget {
final Person? person;
final String? organizationName;
final List<ActItem> items;
final double boxWeight;


  const ActFormPage({super.key, this.person, this.organizationName, required this.items, required this.boxWeight});

  @override
  _ActFormPageState createState() => _ActFormPageState();
}

class _ActFormPageState extends State<ActFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ActInformation _actInformation = ActInformation(); 
  late List<ActItem> adjustedItems;

    // Declare TextEditingControllers for each form field
  late TextEditingController _recipientOrganizationNameController;
  late TextEditingController _recipientNameController;
  late TextEditingController _postNumberController; // Assuming this maps to novaPostBranch
  late TextEditingController _addressController; // Assuming combination of region and city
  late TextEditingController _phoneNumberController;
  
  get pdfFile => null;

    @override
  void initState() {
    super.initState();

    // Initialize controllers with person data if provided, else initialize with empty string
    _recipientOrganizationNameController = TextEditingController(text: widget.organizationName ?? '');
    _recipientNameController = TextEditingController(text: widget.person != null ? '${widget.person!.name} ${widget.person!.surname}' : '');

    _postNumberController = TextEditingController(text: widget.person?.novaPostBranch ?? '');
    _addressController = TextEditingController(text: widget.person != null ? '${widget.person!.region}, ${widget.person!.city}' : '');
    _phoneNumberController = TextEditingController(text: widget.person?.phone ?? '');

    adjustedItems = _adjustItemsWithBoxWeight(widget.items, widget.boxWeight);
  }

    List<ActItem> _adjustItemsWithBoxWeight(List<ActItem> items, double boxWeight) {
    // Calculate the total netto weight of all items
    final totalNettoWeight = items.fold<double>(0.0, (sum, item) => sum + (item.nettoWeight * item.quantity));

    // Calculate the total weight including the box
    final totalWeightWithBox = totalNettoWeight + boxWeight;

    // Distribute the box weight across items based on their proportion of the total weight
    final adjustedItems = items.map((item) {
      final itemProportion = (item.nettoWeight * item.quantity) / totalNettoWeight;
      final adjustedWeight = ((item.nettoWeight * item.quantity) + (boxWeight * itemProportion)) / item.quantity;

      return ActItem(
        number: item.number,
        description: item.description,
        units: item.units,
        packing: item.packing,
        quantity: item.quantity,
        nettoWeight: adjustedWeight,
      );
    }).toList();

    return adjustedItems;
  }

    @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _recipientOrganizationNameController.dispose();
    _recipientNameController.dispose();
    _postNumberController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill Act Information'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                initialValue: _actInformation.reciverFondName,
                decoration: const InputDecoration(labelText: 'Receiver Fond Name'),
                onSaved: (value) {
                  _actInformation.reciverFondName = value ?? '';
                },
              ),
              TextFormField(
                initialValue: _actInformation.reciverFondNumber,
                decoration: const InputDecoration(labelText: 'Receiver Fond Number'),
                onSaved: (value) {
                  _actInformation.reciverFondNumber = value ?? '';
                },
              ),
              TextFormField(
                controller: _recipientOrganizationNameController,
                decoration: const InputDecoration(labelText: 'Recipient organisation'),
                onSaved: (value) {
                  _actInformation.recipientOrganizationName = value ?? '';
                },
              ),
              TextFormField(
                controller: _recipientNameController,
                decoration: const InputDecoration(labelText: 'Recipient Name'),
                onSaved: (value) {
                  _actInformation.recipientName = value ?? '';
                },
              ),
              TextFormField(
                initialValue: _actInformation.recipientNumber,
                decoration: const InputDecoration(labelText: 'Recipient Number'),
                onSaved: (value) {
                  _actInformation.recipientNumber = value ?? '';
                },
              ),
              TextFormField(
                controller: _postNumberController,
                decoration: const InputDecoration(labelText: 'Post Number'),
                onSaved: (value) {
                  _actInformation.postNumber = value ?? '';
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                onSaved: (value) {
                  _actInformation.address = value ?? '';
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) {
                  _actInformation.phoneNumber = value ?? '';
                },
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Generate and View PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }

void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    // Assuming you have a method to gather items for the act
  
    // Populate this list with actual items

    // Generate PDF
    final pdfFile = await ActPdfCreator.createBoxItemsPdf(
      organizationName: _actInformation.reciverFondName,
      organizationNumber: _actInformation.reciverFondNumber,
      recipientOrganizationName: _actInformation.recipientOrganizationName.isEmpty ? null: _actInformation.recipientOrganizationName,
      recipientName: _actInformation.recipientName,
      recipientNumber: _actInformation.recipientNumber.isEmpty ? null : _actInformation.recipientNumber,
      postNumber: _actInformation.postNumber,
      address: _actInformation.address,
      phoneNumber: _actInformation.phoneNumber,
      items: adjustedItems, // Make sure to pass the actual list of items
    );

    // Display the PDF
    if (!kIsWeb) {
        _displayPdf(pdfFile);
    }

  }
}

void _displayPdf(File pdfFile) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PdfPreviewPage(pdfFile: pdfFile,
      ),
    ),
  );

}
}