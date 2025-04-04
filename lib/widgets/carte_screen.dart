import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../models/database/database_helper.dart';
import '../models/location_service.dart';
import '../models/restaurant.dart';

class CarteScreen extends StatefulWidget {
  @override
  _CartePageState createState() => _CartePageState();
}

class _CartePageState extends State<CarteScreen> {
  late final MapController _mapController;
  List<Restaurant> allRestaurants = [];
  List<Restaurant> filteredRestaurants = [];
  TextEditingController searchController = TextEditingController();
  final LocationService locationService = LocationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadRestaurants();
  }

  void _loadRestaurants() async {
    allRestaurants = await DatabaseHelper.getRestaurants();
    setState(() {
      filteredRestaurants = allRestaurants;
      _isLoading = false;
    });
  }

  void _filterRestaurants(String query) {
    setState(() {
      filteredRestaurants = allRestaurants
          .where((restaurant) =>
          restaurant.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<Marker> _buildRestaurantMarkers() {
    return filteredRestaurants.map((restaurant) {
      return Marker(
        point: LatLng(restaurant.latitude, restaurant.longitude),
        width: 25,
        height: 25,
        child: GestureDetector(
          onTap: () {
            context.go('/restaurant/${restaurant.id_restaurant}');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Rechercher un restaurant...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _filterRestaurants,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredRestaurants.isEmpty
          ? Center(child: Text('Aucun restaurant trouvé'))
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(
            filteredRestaurants.first.latitude,
            filteredRestaurants.first.longitude,
          ),
          initialZoom: 13.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.sae_mobile',
          ),
          MarkerLayer(
            markers: _buildRestaurantMarkers(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    searchController.dispose();
    super.dispose();
  }
}