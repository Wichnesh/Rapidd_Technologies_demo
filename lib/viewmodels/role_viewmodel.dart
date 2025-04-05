import 'package:flutter/material.dart';

class RoleViewModel with ChangeNotifier {
  String _role = '';

  String get role => _role;

  void setRole(String newRole) {
    _role = newRole;
    notifyListeners();
  }
}
