import 'package:flutter/material.dart';
import '../components/database_helper.dart';
import '../components/restaurant.dart';

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
            return Center(child: Text('Erreur de chargement : ' + snapshot.error.toString()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun restaurant trouvé'));
          }
          return ListView(
            children: snapshot.data!.map((restaurant) {
              return ListTile(
                title: Text(restaurant.name),
                subtitle: Text(restaurant.operator),
                leading: Icon(Icons.restaurant),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
