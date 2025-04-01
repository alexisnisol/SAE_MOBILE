import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../restaurant.dart';
import 'card_restaurant.dart';
import 'package:geolocator/geolocator.dart';

class CarouselSection extends StatelessWidget {
  final List<Restaurant> restaurants;
  final Position? userPosition;

  const CarouselSection({
    super.key,
    required this.restaurants,
    this.userPosition,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: restaurants.map((restaurant) {
        return RestaurantCard(
          restaurant: restaurant,
          userPosition: userPosition,
        );
      }).toList(),
      options: CarouselOptions(
        autoPlay: false,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.7,
        aspectRatio: 1.3,
        enableInfiniteScroll: true,
      ),
    );
  }
}