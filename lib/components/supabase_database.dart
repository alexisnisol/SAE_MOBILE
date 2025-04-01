import 'package:supabase_flutter/supabase_flutter.dart';

import 'i_database.dart';
import 'restaurant.dart';

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
  GoTrueClient getAuth() {
    return _supabase.auth;
  }

  @override
  bool isConnected() {
    return _isInitialized;
  }

}
