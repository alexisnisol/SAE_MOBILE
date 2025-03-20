import 'package:sae_mobile/components/restaurant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'assets/database.db');
    return openDatabase(path, version: 1);
  }

  static Future<List<Restaurant>> getRestaurants() async {
    final db = await initDb();
    final List<Map<String, dynamic>> maps = await db.query('RESTAURANT');
    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }
}