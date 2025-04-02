import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/location_service.dart';
import '../../models/restaurant.dart';
import 'package:geolocator/geolocator.dart';

import 'card_restaurant.dart';

class CarouselSection extends StatelessWidget {
  final List<Restaurant> restaurants;
  final LocationService locationService;

  const CarouselSection({
    super.key,
    required this.restaurants,
    required this.locationService,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: restaurants.map((restaurant) {
        return RestaurantCard(
          restaurant: restaurant,
          locationService: locationService, // Passez le service
        );
      }).toList(),
      options: CarouselOptions(
        autoPlay: false,
        viewportFraction: 0.7,
        aspectRatio: 1.3,
      ),
    );
  }
}
