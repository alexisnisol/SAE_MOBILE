import 'package:flutter/material.dart';
import '../../models/database/database_helper.dart';
import '../../models/restaurant.dart';
import '../../models/location_service.dart';
import 'title_section.dart';
import 'carousel_section.dart';


class RestaurantCarousel extends StatefulWidget {
  const RestaurantCarousel({super.key});

  @override
  State<RestaurantCarousel> createState() => _RestaurantCarouselState();
}

class _RestaurantCarouselState extends State<RestaurantCarousel> {
  late Future<List<Restaurant>> _restaurantsFuture;
  late Future<void> _locationFuture;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = DatabaseHelper.getRestaurants();
    _locationFuture = _locationService.getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_restaurantsFuture, _locationFuture]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final restaurants = snapshot.data![0] as List<Restaurant>;
        if (restaurants.isEmpty) {
          return const Center(child: Text('Aucun restaurant disponible'));
        }

        return Column(
          children: [
            TitleSection(),
            if (_locationService.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),
            if (_locationService.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _locationService.error!,
                  style: TextStyle(color: Colors.red[600]),
                ),
              ),
            CarouselSection(
              restaurants: restaurants,
              locationService: _locationService, // Passez le service complet
            ),
          ],
        );
      },
    );
  }
}