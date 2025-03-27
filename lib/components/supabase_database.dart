import 'package:sae_mobile/components/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'i_database.dart';
import 'restaurant.dart';
import 'sqlite_database.dart';
import 'review.dart';

class SupabaseDatabase implements IDatabase {
  static bool _isInitialized = false;
  late final SupabaseClient _supabase;

  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      await Supabase.initialize(
        url: 'https://rwvhbldaozvrcotlajbs.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3dmhibGRhb3p2cmNvdGxhamJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczODgwMTUsImV4cCI6MjA1Mjk2NDAxNX0.ouVnoV0SrQsPGNpFqe2wzOXwgZbCUi9IEXsoidca5aE',
      );
      _isInitialized = true;
    }
    _supabase = Supabase.instance.client;
  }

  @override
  Future<List<Restaurant>> getRestaurants() async {
    final List<dynamic> response = await _supabase.from('RESTAURANT').select();
    List<Restaurant> restaurants = response.map((data) {
      return Restaurant.fromMap(data as Map<String, dynamic>);
    }).toList();

    return restaurants;
  }
  @override
  Future<List<Review>> getReviews(id) async {

    final List<dynamic> response = await _supabase.from('AVIS').select().eq('id_utilisateur', id);
    List<Review> reviews = response.map((data) {
      return Review.fromJson(data as Map<String, dynamic>);
    }).toList();

    return reviews;
  }
  @override
  Future<void> deleteReview(int id) async {
    await _supabase.from('AVIS').delete().eq('id_avis', id);
  }

  @override
  Future<Restaurant> getRestaurantById(int id) async {
    final response = await _supabase.from('RESTAURANT').select().eq('id_restaurant', id);
    return Restaurant.fromMap(response[0] as Map<String, dynamic>);
  }

  @override
  bool isConnected() {
    return _isInitialized;
  }
}
