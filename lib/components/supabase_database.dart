import 'package:sae_mobile/components/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'i_database.dart';
import 'restaurant.dart';
import 'sqlite_database.dart';
import 'review.dart';

class SupabaseDatabase implements IDatabase {
  static bool _isInitialized = false;
  late final SupabaseClient _supabase;

  static String _supabaseUrl = 'https://rwvhbldaozvrcotlajbs.supabase.co';
  static String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3dmhibGRhb3p2cmNvdGxhamJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczODgwMTUsImV4cCI6MjA1Mjk2NDAxNX0.ouVnoV0SrQsPGNpFqe2wzOXwgZbCUi9IEXsoidca5aE';

  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        await Supabase.initialize(
          url: _supabaseUrl,
          anonKey: _supabaseAnonKey,
        );
        _isInitialized = true;
      } catch (e) {
        print(e);
        _isInitialized = false;
      }
    }
    _supabase = Supabase.instance.client;
  }

  @override
  Future<List<Restaurant>> getRestaurants() async {
    if (!_isInitialized) await initialize();

    try {
      final List<dynamic> response = await _supabase.from('RESTAURANT').select();
      return response.map((data) => 
        Restaurant.fromMap(data as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      print('Erreur de récupération des restaurants depuis Supabase : $e');
      return [];
    }
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
