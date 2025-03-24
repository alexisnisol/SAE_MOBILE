import 'package:flutter/material.dart';
import '../components/restaurant.dart';
import '../components/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/sqlite_database.dart';

class RestaurantDetailPage extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({Key? key, required this.restaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // Logique pour ajouter aux favoris
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du restaurant
            FutureBuilder<String>(
              future: DatabaseHelper.imageLink(restaurant.name),
              builder: (context, snapshot) {
                final imageUrl = snapshot.data ?? DatabaseHelper.DEFAULT_IMAGE;
                return Container(
                  width: double.infinity,
                  height: 200,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade300,
                      child: Icon(Icons.restaurant, size: 50, color: Colors.grey.shade700),
                    ),
                  ),
                );
              },
            ),

            // Informations du restaurant
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lieu
                  _buildInfoWithData(
                      label: "Lieu : ",
                      value: "${restaurant.region ?? ''}, ${restaurant.departement ?? ''}, ${restaurant.commune ?? ''}"
                  ),

                  // Marque (si disponible)
                  if (restaurant.brand != null && restaurant.brand!.isNotEmpty)
                    _buildInfoWithData(label: "Marque : ", value: restaurant.brand!),

                  // Horaires (si disponible)
                  if (restaurant.opening_hours != null && restaurant.opening_hours!.isNotEmpty)
                    _buildInfoWithData(label: "Horaires : ", value: restaurant.opening_hours!),

                  // Téléphone (si disponible)
                  if (restaurant.phone != null && restaurant.phone!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tel : ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("📞 ${restaurant.phone!}"),
                        IconButton(
                          icon: Icon(Icons.call, size: 18),
                          onPressed: () async {
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: restaurant.phone,
                            );
                            if (await canLaunchUrl(launchUri)) {
                              await launchUrl(launchUri);
                            }
                          },
                        ),
                      ],
                    ),

                  // Note moyenne (à implémenter si nécessaire)
                  // Vous pourriez ajouter une méthode pour récupérer la note moyenne

                  // Services (si disponibles)
                  if (restaurant.hasAnyServices())
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Services : ", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        _buildServicesList(restaurant),
                      ],
                    ),

                  SizedBox(height: 8),

                  // Types de cuisine

                  // Site web (si disponible)
                  if (restaurant.website != null && restaurant.website!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Site web : ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: InkWell(
                            child: Text(
                              restaurant.website!,
                              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            ),
                            onTap: () async {
                              final Uri url = Uri.parse(restaurant.website!);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                  // Section des avis
                  SizedBox(height: 16),
                  Divider(),
                  Text('Les avis :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("${restaurant.name} n'as pas d'avis pour le moment."),
                  ),

                  // Connexion pour avis
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      "Veuillez vous connecter pour laisser un avis...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  // Section de localisation
                  SizedBox(height: 16),
                  Divider(),
                  Text('Localisation :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 50, color: Colors.grey.shade600),
                          SizedBox(height: 8),
                          Text('Carte - Intégrer Google Maps ici'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoWithData({required String label, required String value}) {
    if (value.trim().isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildServicesList(Restaurant restaurant) {
    List<String> services = [];

    if (restaurant.wheelchair == true) services.add("Accès fauteuil roulant");
    if (restaurant.vegetarian == true) services.add("Options végétariennes");
    if (restaurant.vegan == true) services.add("Options véganes");
    if (restaurant.delivery == true) services.add("Livraison");
    if (restaurant.takeaway == true) services.add("À emporter");
    if (restaurant.internet_access == true) services.add("Accès internet");
    if (restaurant.drive_through == true) services.add("Drive-through");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: services.map((service) =>
          Padding(
            padding: EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text(service),
              ],
            ),
          )
      ).toList(),
    );
  }
}

extension RestaurantServiceChecks on Restaurant {
  bool hasAnyServices() {
    return (wheelchair == true) ||
      (vegetarian == true) ||
      (vegan == true) ||
      (delivery == true) ||
      (takeaway == true) ||
      (internet_access == true) ||
      (drive_through == true);
  }
}
