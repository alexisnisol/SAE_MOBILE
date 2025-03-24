import 'i_database.dart';
import 'restaurant.dart';
import 'sqlite_database.dart';
import 'supabase_database.dart';

class DatabaseHelper {
  static late IDatabase _database;

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
  static Future<String> imageLink(String restauName) => _database.imageLink(restauName);
}
