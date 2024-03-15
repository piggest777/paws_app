import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/models/act_information.dart';
import 'package:paws_app/src/models/act_item.dart';
import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/services/act_pdf_creator.dart';
import 'package:paws_app/src/views/view_components/pdf_preview.dart';


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
  double totalAdjustedWeight = 0.0; 

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
    _calculateTotalAdjustedWeight();
  }

List<ActItem> _adjustItemsWithBoxWeight(List<ActItem> items, double boxWeight) {
    // Calculate the total netto weight of all items
    final totalNettoWeight = items.fold<double>(0.0, (sum, item) => sum + item.nettoWeight);

    // Calculate the total weight including the box
    final totalWeightWithBox = totalNettoWeight + boxWeight;

    // Calculate how much weight each item needs to absorb from the box weight, based on their proportion of the total netto weight
    final adjustedItems = items.map((item) {
        // Determine this item's proportion of the total netto weight
        final itemProportion = item.nettoWeight / totalNettoWeight;
        // Calculate the additional weight this item needs to absorb from the box
        final additionalWeightFromBox = boxWeight * itemProportion;
        // Adjust this item's netto weight to include its share of the box weight
        final adjustedNettoWeight = item.nettoWeight + additionalWeightFromBox;

        return ActItem(
            number: item.number,
            description: item.description,
            units: item.units,
            packing: item.packing,
            quantity: item.quantity,
            nettoWeight: adjustedNettoWeight,
        );
    }).toList();

    return adjustedItems;
}

  void _calculateTotalAdjustedWeight() {
    totalAdjustedWeight = adjustedItems.fold<double>(
        0.0, (sum, item) => sum + item.nettoWeight);
    setState(() {
      // Set the state variable with the new total
      totalAdjustedWeight; // Include the box weight in the total
    });
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
              SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Total Adjusted Weight: ${totalAdjustedWeight.toStringAsFixed(2)} kg',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
                          Text(
              'Preview',
              style: Theme.of(context).textTheme.headline6,
            ),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _buildItemsPreviewList(), // Display the compact list here
    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: _submitForm,
      child: Icon(Icons.picture_as_pdf),
      tooltip: 'Generate and View PDF',
    ),
    );
  }

Widget _buildItemsPreviewList() {
  return ListView.separated(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: adjustedItems.length,
    itemBuilder: (context, index) {
      final item = adjustedItems[index];
      return Container(
        padding: EdgeInsets.all(8), // Padding inside each container
        decoration: BoxDecoration(
          color: Colors.white, // Consider using Theme.of(context).canvasColor
          borderRadius: BorderRadius.circular(8), // Rounded corners for the container
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1), // Shadow position
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.label, size: 20, color: Theme.of(context).primaryColor), // Leading icon
            SizedBox(width: 16), // Space between icon and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                  ),
                  SizedBox(height: 4), // Space between description and weight
                  Text(
                    '${item.nettoWeight.toStringAsFixed(2)} kg - Qty: ${item.quantity}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
    separatorBuilder: (context, index) => SizedBox(height: 4), // Space between items
  );
}

void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

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
      items: adjustedItems, 
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