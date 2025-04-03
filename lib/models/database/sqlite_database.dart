import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../restaurant.dart';
import 'i_database.dart';
import '../review.dart';

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
  dynamic getAuth() {
    throw UnimplementedError();
  }

  @override
  dynamic getStorage() {
    throw UnimplementedError();
  }

  @override
  Future<List<Restaurant>> getRestaurants() async {
    if (_database == null) await initialize();
    final List<Map<String, dynamic>> maps = await _database!.query('RESTAURANT');
    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }

  @override
  Future<List<Review>> getReviews(String id) async {
    final List<Map<String, dynamic>> maps = await _database!.query('AVIS', where: 'id_restaurant= ?', whereArgs: [id]);
    return maps.map((map) => Review.fromJson(map)).toList();
  }
  @override
  Future<void> deleteReview(int id) {
    return _database!.delete('AVIS', where: 'id_avis = ?', whereArgs: [id]);
  }
  @override
  Future<Restaurant> getRestaurantById(int id) async {
    final List<Map<String, dynamic>> maps = await _database!.query('RESTAURANT', where: 'id_restaurant = ?', whereArgs: [id]);
    return Restaurant.fromMap(maps.first);
  }

  @override
  bool isConnected() {
    return _database != null;
  }

  @override
  Future<List<Map<String, dynamic>>> getTypeCuisineRestaurant(int id) {
    // TODO: implement getTypeCuisineRestaurant
    throw UnimplementedError();
  }

  @override
  Future<bool> estCuisineLike(String userId, int cuisineId) {
    // TODO: implement estCuisineLike
    throw UnimplementedError();
  }

  @override
  Future<void> dislikeCuisine(String userId, int cuisineId) {
    // TODO: implement dislikeCuisine
    throw UnimplementedError();
  }

  @override
  Future<void> likeCuisine(String userId, int cuisineId) {
    // TODO: implement likeCuisine
    throw UnimplementedError();
  }

  @override
  Future<void> addReview(String userId, int restauId, String avis, int etoiles, DateTime date) {
    // TODO: implement addReview
    throw UnimplementedError();
  }

  @override
  Future<List<Review>> getReviewsRestau(int restauId) {
    // TODO: implement getReviewsRestau
    throw UnimplementedError();
  }

  @override
  Future<List<int>> getRestaurantFavoris(String userId) {
    // TODO: implement getRestaurantFavoris
    throw UnimplementedError();
  }

  @override
  Future<void> deleteRestaurantFavoris(String userId, int restauId) {
    // TODO: implement deleteRestaurantFavoris
    throw UnimplementedError();
  }

  @override
  Future<void> addRestaurantFavoris(String userId, int restauId) {
    // TODO: implement addRestaurantFavoris
    throw UnimplementedError();
  }

  @override
  Future<bool> isRestaurantFavorited(String userId, int restauId) {
    // TODO: implement isRestaurantFavorited
    throw UnimplementedError();
  }

  
}


