import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sae_mobile/models/user.dart';

import 'i_database.dart';
import 'restaurant.dart';
import 'sqlite_database.dart';
import 'supabase_database.dart';

class DatabaseHelper {
  static late IDatabase _database;
  static late List<dynamic> _jsonData;
  static bool _isJsonLoaded = false;

  static const String DEFAULT_IMAGE = "https://raw.githubusercontent.com/Purukitto/pokemon-data.json/refs/heads/master/images/items/sprites/1.png";


  static Future<void> initialize() async {
    IDatabase supabaseDB = SupabaseDatabase();
    await supabaseDB.initialize();

    if (supabaseDB.isConnected()) {
      _database = supabaseDB;
      print("Connexion : Supabase");
    } else {
      _database = SQLiteDatabase();
      await _database.initialize();
      print("Connexion : SQLite");
    }
  }

  static Future<List<Restaurant>> getRestaurants() => _database.getRestaurants();

  static Future<List<UserModel>> getUsers() => _database.getUsers();

  static Future<bool> userExists(String email) async {
    return _database.userExists(email);
  }

  static Future<String> imageLink(String restauName) async {
    if (!_isJsonLoaded) {
      await loadJsonData();
    }

    for (var restaurant in _jsonData) {
      if (restaurant['name'] == restauName) {
        return restaurant['image_url'];
      }
    }
    return DEFAULT_IMAGE;
  }

  static Future<void> loadJsonData() async {
    if (!_isJsonLoaded) {
      String jsonString = await rootBundle.loadString('assets/images.json');
      _jsonData = json.decode(jsonString);
      _isJsonLoaded = true;
    }
  }
}
