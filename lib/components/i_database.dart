import 'package:sae_mobile/models/user.dart';

import 'restaurant.dart';

abstract class IDatabase {

  Future<void> initialize();
  Future<List<Restaurant>> getRestaurants();
  Future<List<UserModel>> getUsers();
  Future<bool> userExists(String email);
  bool isConnected();
}
