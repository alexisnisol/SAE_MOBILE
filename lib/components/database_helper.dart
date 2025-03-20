import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sae_mobile/components/restaurant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Make this a late variable so we can initialize it properly
  static late List<dynamic> _jsonData;
  static bool _isJsonLoaded = false;

  static const String DEFAULT_IMAGE = "https://raw.githubusercontent.com/Purukitto/pokemon-data.json/refs/heads/master/images/items/sprites/1.png";

  static Future<void> loadJsonData() async {
    if (!_isJsonLoaded) {
      String jsonString = await rootBundle.loadString('assets/images.json');
      _jsonData = json.decode(jsonString);
      _isJsonLoaded = true;
    }
  }

  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'assets/database.db');
    return openDatabase(path, version: 1);
  }

  static Future<List<Restaurant>> getRestaurants() async {
    final db = await initDb();
    final List<Map<String, dynamic>> maps = await db.query('RESTAURANT');
    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }

  static Future<String> imageLink(String restauName) async {
    try {
      // Make sure JSON data is loaded
      await loadJsonData();

      for (var restaurant in _jsonData) {
        if (restaurant['name'] == restauName) {
          return restaurant['image_url'];
        }
      }

      return DEFAULT_IMAGE;
    } catch (e) {
      print("Erreur lors de la récupération de l'image: $e");
      return DEFAULT_IMAGE;
    }
  }
}