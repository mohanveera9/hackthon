import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String _name = '';

  // Getters
  String get name => _name;

  // Set user details
  void setUserDetails({
    required String name,
  }) {
    _name = name;
    notifyListeners(); // Notify listeners of updates
  }

  // Update name (e.g., from Profile screen)
  void updateName(String name) {
    _name = name;
    notifyListeners();
  }
}
