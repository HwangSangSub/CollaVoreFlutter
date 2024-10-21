import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier {
  String? _loginId;
  int? _empNo;

  String? get loginId => _loginId;
  int? get empNo => _empNo;

  void login(String id, int empNo) {
    _loginId = id;
    _empNo = empNo;
    notifyListeners();
  }

  void logout() {
    _loginId = null;
    _empNo = null;
    notifyListeners();
  }
}
