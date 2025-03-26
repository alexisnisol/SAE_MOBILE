import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'restaurant.dart';
import 'i_database.dart';

class SQLiteDatabase implements IDatabase {
  static Database? _database;

  @override
  Future<void> initialize() async {
    if (_database != null) {
      return;
    }
    try {
      String path = join(await getDatabasesPath(), 'assets/database.db');
      _database = await openDatabase(
        path, 
        version: 1, 
        onCreate: (Database db, int version) async {
          await db.execute(
            'SELECT * FROM RESTAURANT'
          );
        }
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<List<Restaurant>> getRestaurants() async {
    if (_database == null) await initialize();
    final List<Map<String, dynamic>> maps = await _database!.query('RESTAURANT');
    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }

  @override
  bool isConnected() {
    return _database != null;
  }
}


