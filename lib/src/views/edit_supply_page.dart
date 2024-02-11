import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paws_app/src/models/pet_care_supply_type.dart';
import 'package:paws_app/src/services/firebase_service.dart';
import 'package:paws_app/src/views/view_components/custom_dropdown_list.dart';

class EditSupplyPage extends StatefulWidget {
  final PetCareSupply supplyItem;

  EditSupplyPage({Key? key, required this.supplyItem}) : super(key: key);

  @override
  _EditSupplyPageState createState() => _EditSupplyPageState();
}

class _EditSupplyPageState extends State<EditSupplyPage> {
  final FirebaseService _firebaseService = FirebaseService();

  late TextEditingController nameController;
  late TextEditingController barcodeController;
  late TextEditingController manufacturerController;
  late TextEditingController weightController;

  late TextEditingController forWhomCustomController;
  late TextEditingController supplyTypeCustomController;
  late TextEditingController foodTypeCustomController;
  late TextEditingController packagingCustomController;

  String? selectedForWhom;
  String? selectedSupplyType;
  String? selectedFoodType;
  String? selectedPackaging;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.supplyItem.name);
    barcodeController = TextEditingController(text: widget.supplyItem.barcode ?? '');
    manufacturerController = TextEditingController(text: widget.supplyItem.manufacturer ?? '');
    weightController = TextEditingController(text: widget.supplyItem.weight.toString());

    forWhomCustomController = TextEditingController();
    supplyTypeCustomController = TextEditingController();
    foodTypeCustomController = TextEditingController();
    packagingCustomController = TextEditingController();

    selectedForWhom = widget.supplyItem.forWhom;
    selectedSupplyType = widget.supplyItem.supplyType;
    selectedFoodType = widget.supplyItem.foodType;
    selectedPackaging = widget.supplyItem.packaging;
  }

  void _updateSupplyItem() async {
    // Ensure you add a validation check here similar to AddSupplyPage
    PetCareSupply updatedItem = PetCareSupply(
      id: widget.supplyItem.id,
      name: nameController.text,
      barcode: barcodeController.text.isNotEmpty ? barcodeController.text : null,
      manufacturer: manufacturerController.text.isNotEmpty ? manufacturerController.text : null,
      weight: double.tryParse(weightController.text) ?? 0.0,
      keywords: widget.supplyItem.keywords,
      count: widget.supplyItem.count,
      forWhom: selectedForWhom,
      supplyType: selectedSupplyType,
      foodType: selectedFoodType,
      packaging: selectedPackaging,
    );

    await _firebaseService.updateSupplyItemTypeInFirebase(updatedItem.id, updatedItem.toMap());
    Navigator.of(context).pop(true); // Indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Supply Item'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateSupplyItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: barcodeController,
              decoration: InputDecoration(labelText: 'Barcode (optional)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextFormField(
              controller: manufacturerController,
              decoration: InputDecoration(labelText: 'Manufacturer (optional)'),
            ),
            TextFormField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}'))],
            ),
            SizedBox(height: 16),
            // CustomDropdown<String>(
            //   items: ['Dogs', 'Puppies', 'Cats', 'Rodents', 'Common'],
            //   selectedValue: selectedForWhom,
            //   onChanged: (value) => setState(() => selectedForWhom = value),
            //   hint: 'For Whom',
            //   allowCustom: true,
            //   customController: forWhomCustomController,
            // ),
            // SizedBox(height: 16),
            // CustomDropdown<String>(
            //   items: ['Food', 'Medical', 'Clothes', 'Toys', 'Leashes', 'Cages', 'Common'],
            //   selectedValue: selectedSupplyType,
            //   onChanged: (value) => setState(() => selectedSupplyType = value),
            //   hint: 'Supply Type',
            //   allowCustom: true,
            //   customController: supplyTypeCustomController,
            // ),
            // if (selectedSupplyType == 'Food')  
            //   CustomDropdown<String>(
            //     items: ['Wet', 'Dry'],
            //     selectedValue: selectedFoodType,
            //     onChanged: (value) => setState(() => selectedFoodType = value),
            //     hint: 'Food Type',
            //     allowCustom: true,
            //     customController: foodTypeCustomController,
            //   ),
            //   SizedBox(height: 16),
            // CustomDropdown<String>(
            //   items: ['Tins', 'Jars', 'Bags', 'Boxes', 'None'],
            //   selectedValue: selectedPackaging,
            //   onChanged: (value) => setState(() => selectedPackaging = value),
            //   hint: 'Packaging',
            //   allowCustom: true,
            //   customController: packagingCustomController,
            // ),
          ],
        ),
      ),
    );
  }
}
