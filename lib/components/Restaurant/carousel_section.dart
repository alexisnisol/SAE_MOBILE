import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../restaurant.dart';
import 'card_restaurant.dart';

class CarouselSection extends StatelessWidget {
  final List<Restaurant> restaurants;

  const CarouselSection({super.key, required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: restaurants.map((restaurant) {
        return RestaurantCard(restaurant: restaurant);
      }).toList(),
      options: CarouselOptions(
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.7,
        aspectRatio: 1.3,
        enableInfiniteScroll: true,
      ),
    );
  }
}