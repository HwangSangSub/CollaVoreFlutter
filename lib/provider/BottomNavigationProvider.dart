import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier {
  String? _curIndex;

  String? get curIndex => _curIndex;

  void login(String curIndex) {
    curIndex = curIndex;
    notifyListeners();
  }
}
