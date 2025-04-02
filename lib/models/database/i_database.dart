import 'package:sae_mobile/models/review.dart';

import '../restaurant.dart';

abstract class IDatabase {

  Future<void> initialize();
  Future<List<Restaurant>> getRestaurants();
  dynamic getAuth();
  dynamic getStorage();
  Future<List<Map<String, dynamic>>> getTypeCuisineRestaurant(int id);
  Future<List<Review>> getReviews(String id);
  Future<List<Review>> getReviewsRestau(int restauId);
  Future<void> deleteReview(int id);
  Future<void> addReview(String userId, int restauId, String avis, int etoiles, DateTime date);
  Future<Restaurant> getRestaurantById(int id);
  bool isConnected();
  Future<bool> estCuisineLike(String userId, int cuisineId);
  Future<void> likeCuisine(String userId, int cuisineId);
  Future<void> dislikeCuisine(String userId, int cuisineId);
  Future<List<int>> getRestaurantFavoris(String userId);
  Future<void> deleteRestaurantFavoris(String userId, int restauId);
  Future<void> addRestaurantFavoris(String userId, int restauId);
  Future<bool> isRestaurantFavorited(String userId, int restauId);


}
