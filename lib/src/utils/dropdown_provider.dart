import 'package:flutter/foundation.dart';

class DropdownProvider with ChangeNotifier {
  List<String> _items = ['Dogs', 'Puppies', 'Cats', 'Rodents', 'Common'];
  String? _selectedItem;

  List<String> get items => _items;
  String? get selectedItem => _selectedItem;

  void selectItem(String? value) {
    _selectedItem = value;
    notifyListeners();
  }

  void addCustomItem(String value) {
    if (!_items.contains(value)) {
      _items.add(value);
      selectItem(value);
    }
  }
}
