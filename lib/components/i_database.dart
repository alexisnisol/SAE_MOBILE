import 'restaurant.dart';

abstract class IDatabase {

  Future<void> initialize();
  Future<List<Restaurant>> getRestaurants();
  bool isConnected();
}
