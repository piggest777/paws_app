import 'package:flutter/material.dart';

class GroupExpandedState with ChangeNotifier {
  final Map<String, bool> _groupExpandedState = {};

  Map<String, bool> get groupExpandedState => _groupExpandedState;

  void toggle(String date) {
    _groupExpandedState[date] = !(_groupExpandedState[date] ?? false);
    notifyListeners();
  }
}
