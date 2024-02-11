import 'package:flutter/material.dart';

class FormStateProvider with ChangeNotifier {
  String? _selectedSupplyType;

  String? get selectedSupplyType => _selectedSupplyType;

  set selectedSupplyType(String? value) {
    _selectedSupplyType = value;
    notifyListeners();
  }

  // Include other form fields and logic as necessary
}