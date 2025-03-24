import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'restaurant.dart';
import 'i_database.dart';

class SQLiteDatabase implements IDatabase {
  static late Database _database;
  static late List<dynamic> _jsonData;
  static bool _isJsonLoaded = false;
  static const String DEFAULT_IMAGE = "https://raw.githubusercontent.com/Purukitto/pokemon-data.json/refs/heads/master/images/items/sprites/1.png";

  @override
  Future<void> initialize() async {
    String path = join(await getDatabasesPath(), 'assets/database.db');
    _database = await openDatabase(path, version: 1);
  }

  @override
  Future<List<Restaurant>> getRestaurants() async {
    final List<Map<String, dynamic>> maps = await _database.query('RESTAURANT');
    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }

  @override
  Future<String> imageLink(String restauName) async {
    try {
      if (!_isJsonLoaded) {
        String jsonString = await rootBundle.loadString('assets/images.json');
        _jsonData = json.decode(jsonString);
        _isJsonLoaded = true;
      }
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

  @override
  bool isConnected() {
    return true;
  }
}


