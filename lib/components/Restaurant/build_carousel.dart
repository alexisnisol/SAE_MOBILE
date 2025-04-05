import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/database/database_helper.dart';
import '../../models/restaurant.dart';
import '../../models/location_service.dart';
import 'card_restaurant.dart';

class RestaurantCarousel extends StatefulWidget {
  final String title;
  final TextStyle? titleStyle;
  final bool Function(Restaurant, LocationService)? filter;

  const RestaurantCarousel({
    super.key,
    required this.title,
    this.titleStyle,
    this.filter,
  });

  @override
  State<RestaurantCarousel> createState() => _RestaurantCarouselState();
}

class _RestaurantCarouselState extends State<RestaurantCarousel> {
  late Future<List<Restaurant>> _restaurantsFuture;
  final LocationService _locationService = LocationService();
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = DatabaseHelper.getRestaurants();
    _locationService.getUserLocation(false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            widget.title,
            style: widget.titleStyle ?? Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FutureBuilder<List<Restaurant>>(
          future: _restaurantsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            List<Restaurant> restaurants = snapshot.data ?? [];
            if (widget.filter != null) {
              restaurants = restaurants.where((r) => widget.filter!(r, _locationService)).toList();
            }

            return CarouselSlider(
              items: restaurants.map((restaurant) {
                return RestaurantCard(
                  restaurant: restaurant,
                  locationService: _locationService,
                );
              }).toList(),
              options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                aspectRatio: 1.35,
                enableInfiniteScroll: true,
                scrollPhysics: const BouncingScrollPhysics(),
              ),
            );
          },
        ),
      ],
    );
  }
}