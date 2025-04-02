import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/models/review.dart';
import '../models/restaurant.dart';
import '../models/database/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/auth_helper.dart';

class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;
  static String? CURRENT_USER_ID = AuthHelper.getCurrentUser().id;

  const RestaurantDetailPage({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  Map<int, bool> likedCuisines = {};
  final TextEditingController _avisController = TextEditingController();
  int _selectedRating = 3;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  // Vérifie si le restaurant est déjà favorisé pour l'utilisateur courant.
  Future<void> _checkIfFavorited() async {
    if (RestaurantDetailPage.CURRENT_USER_ID != null) {
      bool favorited = await DatabaseHelper.isRestaurantFavorited(
          RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId);
      setState(() {
        _isFavorited = favorited;
      });
    }
  }

  // Bascule l'état du favori et met à jour la base de données.
  Future<void> _toggleFavorite() async {
    if (RestaurantDetailPage.CURRENT_USER_ID == null) return;

    if (_isFavorited) {
      await DatabaseHelper.deleteRestaurantFavoris(
          RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId);
    } else {
      await DatabaseHelper.addRestaurantFavoris(
          RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId);
    }
    _checkIfFavorited();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Restaurant>(
      future: DatabaseHelper.getRestaurantById(widget.restaurantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Restaurant introuvable.")),
          );
        }

        final restaurant = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/carte');
              },
            ),
            title: Text(restaurant.name),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: _toggleFavorite,
              ),
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
                    final imageUrl =
                        snapshot.data ?? DatabaseHelper.DEFAULT_IMAGE;
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
                          child: Icon(Icons.restaurant,
                              size: 50, color: Colors.grey.shade700),
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
                      Text(
                        restaurant.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      _buildInfoWithData(
                        label: "Lieu : ",
                        value:
                        "${restaurant.region ?? ''}, ${restaurant.departement ?? ''}, ${restaurant.commune ?? ''}",
                      ),
                      if (restaurant.brand != null &&
                          restaurant.brand!.isNotEmpty)
                        _buildInfoWithData(
                            label: "Marque : ", value: restaurant.brand!),
                      if (restaurant.opening_hours != null &&
                          restaurant.opening_hours!.isNotEmpty)
                        _buildInfoWithData(
                            label: "Horaires : ",
                            value: restaurant.opening_hours!),
                      if (restaurant.phone != null &&
                          restaurant.phone!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Tel : ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
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
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseHelper.getTypeCuisineRestaurant(
                            widget.restaurantId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Chargement des types de cuisine...");
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return SizedBox.shrink();
                          }
                          final cuisines = snapshot.data!;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Type de cuisine : ",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: cuisines.map((cuisine) {
                                    if (RestaurantDetailPage.CURRENT_USER_ID !=
                                        null) {
                                      return FutureBuilder<bool>(
                                        future: DatabaseHelper.estCuisineLike(
                                            RestaurantDetailPage.CURRENT_USER_ID!,
                                            cuisine["id"]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return SizedBox(
                                                width: 24, height: 24);
                                          }
                                          bool isLiked = snapshot.data ?? false;
                                          return Chip(
                                            label: GestureDetector(
                                              onTap: () async {
                                                bool newLikeStatus = !isLiked;
                                                 DatabaseHelper.toggleCuisineLike(
                                                    RestaurantDetailPage
                                                        .CURRENT_USER_ID!,
                                                    cuisine["id"],
                                                    newLikeStatus);
                                                setState(() {
                                                  likedCuisines[cuisine["id"]] =
                                                      newLikeStatus;
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    size: 16,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(cuisine["cuisine"]),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return Chip(
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.restaurant,
                                                size: 16, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(cuisine["cuisine"]),
                                          ],
                                        ),
                                      );
                                    }
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (restaurant.wheelchair == true ||
                          restaurant.vegetarian == true ||
                          restaurant.vegan == true ||
                          restaurant.delivery == true ||
                          restaurant.takeaway == true ||
                          restaurant.internet_access == true ||
                          restaurant.drive_through == true)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildServicesList(restaurant),
                          ],
                        ),
                      SizedBox(height: 8),
                      if (restaurant.website != null &&
                          restaurant.website!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Site web : ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: InkWell(
                                child: Text(
                                  restaurant.website!,
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                ),
                                onTap: () async {
                                  final Uri url = Uri.parse(restaurant.website!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      Divider(),
                      if (RestaurantDetailPage.CURRENT_USER_ID != null) ...[
                        SizedBox(height: 16),
                        Text('Laisser un avis :',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Note : ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(
                                5,
                                    (index) => IconButton(
                                  icon: Icon(
                                    index < _selectedRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedRating = index + 1;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _avisController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Votre avis...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end, // Aligner à droite
                          children: [
                            ElevatedButton(
                              onPressed: _submitReview,
                              child: Text("Envoyer l'avis"),
                            ),
                          ],
                        ),
                      ] else
                        Center(
                          child: Text(
                            "Veuillez vous connecter pour laisser un avis...",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      Text('Les avis :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      FutureBuilder<List<Review>>(
                        future: DatabaseHelper.getReviewsRestau(widget.restaurantId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Chargement des avis...");
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                  "${restaurant.name} n'a pas d'avis pour le moment."),
                            );
                          }
                          final lesAvis = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: lesAvis.map((avis) {
                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Utilisateur ${avis.userId}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Spacer(),
                                        Row(
                                          children: List.generate(
                                            5,
                                                (index) => Icon(
                                              index < avis.etoiles
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${avis.date.day}/${avis.date.month}/${avis.date.year}",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                    SizedBox(height: 4),
                                    Text(avis.avis),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      Text('Localisation :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
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
                              Icon(Icons.map,
                                  size: 50, color: Colors.grey.shade600),
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
      },
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
    if (restaurant.internet_access == true) services.add("Wi-Fi");
    if (restaurant.drive_through == true) services.add("Drive-through");
    if (services.isEmpty) return const SizedBox();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Services : ",
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: services.map((service) {
            return Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(service),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _submitReview() async {
    if (_avisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez écrire un avis avant d'envoyer.")),
      );
      return;
    }
    await DatabaseHelper.addReview(
      RestaurantDetailPage.CURRENT_USER_ID!,
      widget.restaurantId,
      _avisController.text,
      _selectedRating,
      DateTime.now(),
    );
    _avisController.clear();
    setState(() {
      _selectedRating = 3;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Avis ajouté avec succès !")),
    );
  }
}
