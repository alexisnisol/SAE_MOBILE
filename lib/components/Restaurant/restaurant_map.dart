import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/restaurant.dart';
import '../services/location_service.dart';

class RestaurantMap extends StatefulWidget {
  final Restaurant restaurant;
  final LocationService locationService;
  final bool showUserLocation;
  final bool showRouteLine;
  final double height;

  const RestaurantMap({
    Key? key,
    required this.restaurant,
    required this.locationService,
    this.showUserLocation = true,
    this.showRouteLine = true,
    this.height = 250,
  }) : super(key: key);

  @override
  _RestaurantMapState createState() => _RestaurantMapState();
}

class _RestaurantMapState extends State<RestaurantMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _adjustMapView());
  }

  void _adjustMapView() {
    if (widget.showUserLocation && widget.locationService.hasValidPosition) {
      final userPos = widget.locationService.userPosition!;
      final bounds = LatLngBounds(
        LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
        LatLng(userPos.latitude, userPos.longitude),
      );
      _mapController.fitBounds(bounds, padding: const EdgeInsets.all(70));
    } else {
      _mapController.move(
        LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
        15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(
            widget.restaurant.latitude,
            widget.restaurant.longitude,
          ),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.sae_mobile',
          ),
          MarkerLayer(
            markers: _buildMarkers(),
          ),
          if (widget.showRouteLine && widget.locationService.hasValidPosition)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    LatLng(
                      widget.locationService.userPosition!.latitude,
                      widget.locationService.userPosition!.longitude,
                    ),
                    LatLng(
                      widget.restaurant.latitude,
                      widget.restaurant.longitude,
                    ),
                  ],
                  color: Colors.blue.withOpacity(0.7),
                  strokeWidth: 3,
                ),
              ],
            ),
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return [
      Marker(
        point: LatLng(
          widget.restaurant.latitude,
          widget.restaurant.longitude,
        ),
        width: 40,
        height: 40,
        builder: (ctx) => const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      ),
      if (widget.showUserLocation && widget.locationService.hasValidPosition)
        Marker(
          point: LatLng(
            widget.locationService.userPosition!.latitude,
            widget.locationService.userPosition!.longitude,
          ),
          builder: (ctx) => const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 40,
          ),
        ),
    ];
  }
}