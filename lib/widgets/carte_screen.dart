import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/database/database_helper.dart';
import '../models/restaurant.dart';

class CarteScreen extends StatefulWidget {
  @override
  _CartePageState createState() => _CartePageState();
}

class _CartePageState extends State<CarteScreen> {
  late Future<List<Restaurant>> futureRestaurants;
  List<Restaurant> allRestaurants = [];
  List<Restaurant> filteredRestaurants = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  void _loadRestaurants() async {
    allRestaurants = await DatabaseHelper.getRestaurants();
    setState(() {
      filteredRestaurants = allRestaurants;
    });
  }

  void _filterRestaurants(String query) {
    setState(() {
      filteredRestaurants = allRestaurants
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Rechercher un restaurant...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _filterRestaurants, // Filtre en temps réel
        ),
      ),
      body: filteredRestaurants.isEmpty
          ? Center(child: Text('Aucun restaurant trouvé'))
          : ListView.builder(
              itemCount: filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = filteredRestaurants[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: InkWell(
                    onTap: () {
                      // Navigation vers la page de détail via GoRouter
                      context.go('/restaurant/${restaurant.id_restaurant}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          FutureBuilder<String>(
                            future: DatabaseHelper.imageLink(restaurant.name),
                            builder: (context, imageSnapshot) {
                              final imageUrl = imageSnapshot.data ??
                                  DatabaseHelper.DEFAULT_IMAGE;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(restaurant.commune),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
