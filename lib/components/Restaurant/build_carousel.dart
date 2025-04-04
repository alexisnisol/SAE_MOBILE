import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/database/database_helper.dart';
import '../../models/restaurant.dart';
import '../../models/location_service.dart';
import '../../models/viewmodels/settings_viewmodel.dart';
import 'title_section.dart';
import 'carousel_section.dart';

class RestaurantCarousel extends StatefulWidget {
  final String title;
  final bool Function(Restaurant, LocationService)? filter;

  const RestaurantCarousel({
    super.key,
    required this.title,
    this.filter,
  });

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
  }

  @override
  Widget build(BuildContext context) {
    _locationFuture = _locationService.getUserLocation(context.watch<SettingsViewModel>().isGeolocationDisabled);

    return FutureBuilder(
      future: Future.wait([_restaurantsFuture, _locationFuture]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        List<Restaurant> restaurants = snapshot.data![0] as List<Restaurant>;

        // Appliquer le filtre si présent
        if (widget.filter != null) {
          restaurants = restaurants.where((r) => widget.filter!(r, _locationService)).toList();
        }

        if (restaurants.isEmpty) {
          return const SizedBox(); // Ne rien afficher si aucun résultat
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleSection(title: widget.title),
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
              locationService: _locationService,
            ),
          ],
        );
      },
    );
  }
}