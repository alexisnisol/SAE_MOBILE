import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart';
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
  Future<List<UserModel>> getUsers() async {
    final List<dynamic> response = await _supabase.from('UTILISATEUR').select();
    List<UserModel> users = response.map((data) {
      return UserModel.fromMap(data as Map<String, dynamic>);
    }).toList();
    debugPrint("Message" + users.toString());
    return users;
  }

  @override
  Future<bool> userExists(String email) async {
    final List<dynamic> response = await _supabase.from('UTILISATEUR').select().eq('email', email);
    List<UserModel> users = response.map((data) {
      return UserModel.fromMap(data as Map<String, dynamic>);
    }).toList();
    return users.isNotEmpty;
  }

  Future<void> signUpNewUser(String email, String password) async {
    final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  bool isConnected() {
    return _isInitialized;
  }

}
