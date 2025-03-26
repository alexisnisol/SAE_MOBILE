import 'package:flutter/material.dart';

import '../../components/database_helper.dart';
import '../user.dart';

class AuthenticationService extends ChangeNotifier {

  late UserModel _user;

  UserModel get user => _user;

  Future<void> register(UserModel user) async {
    final userExists = await DatabaseHelper.userExists(user.email);
    if (userExists) {
      throw Exception('User already exists: '+ userExists.toString() + ' ' + user.email);
    } else {
      _user = user;
      notifyListeners();
    }
  }

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }


}