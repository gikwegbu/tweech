import 'package:flutter/material.dart';
import 'package:tweech/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(uid: '', username: '', email: '');

  User get user => _user;

  setUser(User user) {
    _user = user;
    notifyListeners();
  }

  updateUser(User user) {
    _user = User(uid: '', username: '', email: '');
    notifyListeners();
  }

  clearUser() {
    _user = User(uid: '', username: '', email: '');
    notifyListeners();
  }
}
