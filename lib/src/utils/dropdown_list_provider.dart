import 'package:flutter/foundation.dart';


class DropdownItemsProvider<T> with ChangeNotifier {
  final List<T> _items;
  T? _selectedItem;

  DropdownItemsProvider(this._items);

  List<T> get items => _items;
  T? get selectedItem => _selectedItem;

  void addItem(T item) {
    // Check if the item is already in the list to prevent duplicates
    if (!_items.contains(item)) {
      print("Adding item to provider: $item");
      _items.add(item);
      notifyListeners();
    } else {
      print("Attempted to add duplicate item to provider: $item");
    }
  }

  void setSelectedItem(T? item) {
    // Debug message for when a selected item is set
    print("Setting selected item in provider to: $item");
    _selectedItem = item;
    notifyListeners();
  }
}



