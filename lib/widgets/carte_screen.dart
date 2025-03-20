import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Restaurant {
  final String name;

  Restaurant({required this.name});

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(name: map['name']);
  }
}

class DatabaseHelper {
  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'assets/database.db');
    return openDatabase(path, version: 1);
  }

  static Future<List<Restaurant>> getRestaurants() async {
    final db = await initDb();
    final List<Map<String, dynamic>> maps = await db.query('RESTAURANT', columns: ['name']);
    return maps.map((map) => Restaurant.fromMap(map)).toList();
  }
}

class CartePage extends StatefulWidget {
  @override
  _CartePageState createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  late Future<List<Restaurant>> futureRestaurants;

  @override
  void initState() {
    super.initState();
    futureRestaurants = DatabaseHelper.getRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Restaurants')),
      body: FutureBuilder<List<Restaurant>>(
        future: futureRestaurants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement :' + snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun restaurant trouvé'));
          }
          return ListView(
            children: snapshot.data!.map((restaurant) {
              return ListTile(
                title: Text(restaurant.name),
                leading: Icon(Icons.restaurant),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
