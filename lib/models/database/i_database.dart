import 'package:sae_mobile/models/review.dart';

import '../restaurant.dart';

abstract class IDatabase {

  Future<void> initialize();
  Future<List<Restaurant>> getRestaurants();
  dynamic getAuth();
  Future<List<Map<String, dynamic>>> getTypeCuisineRestaurant(int id);
  Future<List<Review>> getReviews(int id);
  Future<List<Review>> getReviewsRestau(int restauId);
  Future<void> deleteReview(int id);
  Future<void> addReview(int userId, int restauId, String avis, int etoiles, DateTime date);
  Future<Restaurant> getRestaurantById(int id);
  bool isConnected();
  Future<bool> estCuisineLike(int userId, int cuisineId);
  Future<void> likeCuisine(int userId, int cuisineId);
  Future<void> dislikeCuisine(int userId, int cuisineId);
  Future<List<int>> getRestaurantFavoris(int userId);
  Future<void> deleteRestaurantFavoris(int userId, int restauId);
  Future<void> addRestaurantFavoris(int userId, int restauId);
  Future<bool> isRestaurantFavorited(int userId, int restauId);


}
