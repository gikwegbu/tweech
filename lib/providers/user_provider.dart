import 'package:flutter/material.dart';
import 'package:tweech/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    uid: '',
    username: '',
    email: '',
  );

  User get user => _user;

  setUser(User user) {
    _user = user;
    notifyListeners();
  }

  updateUser(User user) {
    print("Yeah, i'm updating the user profile");
    _user = user;
    print("George this is the new User: ${user.toMap()}");
    notifyListeners();
  }

  clearUser() {
    _user = User(uid: '', username: '', email: '');
    notifyListeners();
  }
}
