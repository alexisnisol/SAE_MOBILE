import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/database/database_helper.dart';
import '../models/restaurant.dart';
import '../models/helper/auth_helper.dart';

class GroupedFavorisPage extends StatefulWidget {
  const GroupedFavorisPage({super.key});

  @override
  State<GroupedFavorisPage> createState() => _GroupedFavorisPageState();
}

class _GroupedFavorisPageState extends State<GroupedFavorisPage> {
  late Future<Map<String, List<Restaurant>>> futureGroupedFavoris;
  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    futureGroupedFavoris = _loadGroupedFavoris();
  }

  /// Cette fonction récupère la liste des favoris (les id des restaurants) pour l'utilisateur 1,
  /// puis pour chaque id, elle récupère les détails du restaurant et son type de cuisine.
  /// Les restaurants sont ensuite regroupés par type de cuisine.
  Future<Map<String, List<Restaurant>>> _loadGroupedFavoris() async {
    List<int> favoriteIds = await DatabaseHelper.getRestaurantFavoris(
        AuthHelper.getCurrentUser().id);
    Map<String, List<Restaurant>> groupedFavoris = {};

    for (int restaurantId in favoriteIds) {
      Restaurant restaurant =
          await DatabaseHelper.getRestaurantById(restaurantId);

      List<Map<String, dynamic>> types =
          await DatabaseHelper.getTypeCuisineRestaurant(
              restaurant.id_restaurant);
      String cuisineType =
          types.isNotEmpty ? types.first["cuisine"].toString() : "Autre";

      if (groupedFavoris.containsKey(cuisineType)) {
        groupedFavoris[cuisineType]!.add(restaurant);
      } else {
        groupedFavoris[cuisineType] = [restaurant];
      }
    }

    return groupedFavoris;
  }

  Future<void> _deleteFavorite(int restaurantId) async {
    await DatabaseHelper.deleteRestaurantFavoris(
        AuthHelper.getCurrentUser().id, restaurantId);
    setState(() {
      futureGroupedFavoris = _loadGroupedFavoris();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favoris',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, List<Restaurant>>>(
        future: futureGroupedFavoris,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun favori pour le moment."));
          }

          final groupedFavoris = snapshot.data!;
          List<Widget> sections = [];

          // Pour chaque type de cuisine, on ajoute un titre et la liste des restaurants correspondants.
          groupedFavoris.forEach((cuisineType, restaurants) {
            // Titre de la section
            sections.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cuisineType,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ));
            // Pour chaque restaurant du groupe, on affiche une carte avec ses informations
            for (var restaurant in restaurants) {
              sections.add(Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: FutureBuilder<String>(
                    future: DatabaseHelper.imageLink(restaurant.name),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(child: CircularProgressIndicator()));
                      } else if (imageSnapshot.hasError ||
                          imageSnapshot.data == null) {
                        return Image.asset(
                          'assets/images/default_restaurant.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageSnapshot.data!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    },
                  ),
                  title: Text(
                    restaurant.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(restaurant.operator ?? ""),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteFavorite(restaurant.id_restaurant);
                    },
                  ),
                  onTap: () {
                    // Navigation vers la page de détails du restaurant
                    context.go('/restaurant/${restaurant.id_restaurant}');
                  },
                ),
              ));
            }
          });

          return ListView(
            children: sections,
          );
        },
      ),
    );
  }
}
