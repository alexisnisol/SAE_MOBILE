import 'package:flutter/material.dart';

import '../User.dart';

class CurrentUser extends ChangeNotifier {

  late User _user;

  User get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}