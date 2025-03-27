import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sae_mobile/components/review.dart';

import 'i_database.dart';
import 'restaurant.dart';
import 'sqlite_database.dart';
import 'supabase_database.dart';

class DatabaseHelper {
  static IDatabase? _database;
  static List<dynamic>? _jsonData;
  static bool _isJsonLoaded = false;

  static const String DEFAULT_IMAGE = "https://raw.githubusercontent.com/Purukitto/pokemon-data.json/refs/heads/master/images/items/sprites/1.png";


  static Future<IDatabase> initialize() async {
    try {
      IDatabase supabaseDB = SupabaseDatabase();
      await supabaseDB.initialize();

      if (supabaseDB.isConnected()) {
        _database = supabaseDB;
        print("Connexion : Supabase");

        return _database!;
      } else {
        _database = SQLiteDatabase();
        await _database!.initialize();
        print("Connexion : SQLite");

        return _database!;
      }
    } catch (e) {
      _database = SQLiteDatabase();
      await _database!.initialize();
      print("Connexion : SQLite (erreur complète)");
      
      return _database!;
    }
  }

  static Future<List<Restaurant>> getRestaurants() async {
    if (_database == null) await initialize();
    return _database!.getRestaurants();
  }

  static Future<List<Review>> getReviews(int id) => _database.getReviews(id);

  static Future<void> deleteReview(int id) => _database.deleteReview(id);
  static Future<Restaurant> getRestaurantById(int id) => _database.getRestaurantById(id);

  static Future<String> imageLink(String restauName) async {
    if (!_isJsonLoaded) {
      await loadJsonData();
    }

    if (_jsonData != null) {
      for (var restaurant in _jsonData!) {
        if (restaurant['name'] == restauName) {
          return restaurant['image_url'] ?? DEFAULT_IMAGE;
        }
      }
    }
    return DEFAULT_IMAGE;
  }

  static Future<void> loadJsonData() async {
    if (!_isJsonLoaded) {
      try {
        String jsonString = await rootBundle.loadString('assets/images.json');
        _jsonData = json.decode(jsonString);
        _isJsonLoaded = true;
      } catch (e) {
        print('Erreur de chargement des données JSON : $e');
        _jsonData = [];
      }
    }
  }
}
