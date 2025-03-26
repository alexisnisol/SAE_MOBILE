import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../restaurant.dart';
import 'title_section.dart';
import 'carousel_section.dart';

class RestaurantCarousel extends StatefulWidget {
  const RestaurantCarousel({super.key});

  @override
  State<RestaurantCarousel> createState() => _RestaurantCarouselState();
}

class _RestaurantCarouselState extends State<RestaurantCarousel> {
  late Future<List<Restaurant>> _restaurantsFuture;

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = DatabaseHelper.getRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Restaurant>>(
      future: _restaurantsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun restaurant disponible'));
        }

        return Column(
          children: [
            TitleSection(),
            CarouselSection(restaurants: snapshot.data!),
          ],
        );
      },
    );
  }
}