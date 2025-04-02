import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// Classe principale pour afficher le carousel des restaurants
class RestaurantCarousel extends StatelessWidget {
  final List<Map<String, String>> restaurants = [
    {"name": "Le Gourmet", "rating": "4.5", "cuisine": "Française"},
    {"name": "Chez Marie", "rating": "4.7", "cuisine": "Italienne"},
    {"name": "L'Épicurien", "rating": "4.2", "cuisine": "Espagnole"},
    {"name": "Bistro 42", "rating": "4.8", "cuisine": "Américaine"},
    {"name": "Le Petit Chef", "rating": "4.6", "cuisine": "Indienne"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleSection(),  // Titre à gauche
        CarouselSection(restaurants: restaurants),  // Carousel des restaurants
      ],
    );
  }
}

// Classe pour le titre "Nos Restaurants"
class TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Nos Restaurants',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

// Classe pour le carousel des restaurants
class CarouselSection extends StatelessWidget {
  final List<Map<String, String>> restaurants;

  CarouselSection({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: restaurants.map((restaurant) {
        return RestaurantCard(restaurant: restaurant);
      }).toList(),
      options: CarouselOptions(
        autoPlay: false,
        viewportFraction: 0.7,
        aspectRatio: 1.3,  // Ratio légèrement augmenté
        enableInfiniteScroll: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

// Classe pour afficher chaque carte de restaurant
class RestaurantCard extends StatelessWidget {
  final Map<String, String> restaurant;

  RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stack pour l'image et le bouton like
          Stack(
            children: [
              // Image du restaurant (carré bleu)
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
              ),
              // Bouton like sans fond blanc
              Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                  size: 28,  // Taille légèrement augmentée
                ),
              ),
            ],
          ),
          // Contenu textuel réduit
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),  // Padding réduit
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du restaurant
                Text(
                  restaurant["name"]!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,  // Taille légèrement réduite
                  ),
                ),
                SizedBox(height: 2),  // Espacement réduit
                // Type de cuisine
                Text(
                  restaurant["cuisine"]!,
                  style: TextStyle(
                    fontSize: 14,  // Taille légèrement réduite
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),  // Espacement réduit
                // Note du restaurant
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 18),
                    SizedBox(width: 4),
                    Text(
                      restaurant["rating"]!,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,  // Taille légèrement réduite
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}