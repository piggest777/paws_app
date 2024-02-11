import 'package:flutter/foundation.dart';


class DropdownItemsProvider<T> with ChangeNotifier {
  List<T> _items;
  T? _selectedItem;

  DropdownItemsProvider(this._items);

  List<T> get items => _items;
  T? get selectedItem => _selectedItem;

  void addItem(T item) {
    _items.add(item);
    notifyListeners();
  }

  void setSelectedItem(T? item) {
    _selectedItem = item;
    notifyListeners();
  }
}


