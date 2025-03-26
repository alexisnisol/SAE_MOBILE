import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import 'restaurant.dart';
import 'i_database.dart';

class SQLiteDatabase implements IDatabase {
  static late Database _database;

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
  Future<List<UserModel>> getUsers() async {
    final List<Map<String, dynamic>> maps = await _database.query('UTILISATEUR');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  @override
  Future<bool> userExists(String email) async {
    final List<Map<String, dynamic>> maps = await _database.query('UTILISATEUR', where: 'email = ?', whereArgs: [email]);
    return maps.isNotEmpty;
  }

  @override
  bool isConnected() {
    return true;
  }
}


