import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'restaurant_card.dart';

class CarouselSection extends StatelessWidget {
  final List<Map<String, String>> restaurants;

  const CarouselSection({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: restaurants.map((restaurant) {
        return RestaurantCard(restaurant: restaurant);
      }).toList(),
      options: CarouselOptions(
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3), // Ajoutez ceci
        autoPlayAnimationDuration: const Duration(milliseconds: 800), // Ajoutez ceci
        viewportFraction: 0.7,
        aspectRatio: 1.3,
        enableInfiniteScroll: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}