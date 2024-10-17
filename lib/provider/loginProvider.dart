import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier {
  String? _loginId;

  String? get loginId => _loginId;

  void login(String id) {
    _loginId = id;
    notifyListeners();
  }

  void logout() {
    _loginId = null;
    notifyListeners();
  }
}
