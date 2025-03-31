import 'package:sae_mobile/models/review.dart';

import '../restaurant.dart';

abstract class IDatabase {

  Future<void> initialize();
  Future<List<Restaurant>> getRestaurants();
  Future<List<Map<String, dynamic>>> getTypeCuisineRestaurant(int id);
  Future<List<Review>> getReviews(int id);
  Future<void> deleteReview(int id);
  Future<Restaurant> getRestaurantById(int id);
  bool isConnected();

}
