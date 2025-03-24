import 'restaurant.dart';

abstract class IDatabase {

  Future<void> initialize();
  Future<List<Restaurant>> getRestaurants();
  Future<String> imageLink(String restauName);
  bool isConnected();
}
