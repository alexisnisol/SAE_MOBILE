import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/location_service.dart';
import '../../models/restaurant.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantMap extends StatefulWidget {
  final Restaurant restaurant;
  final LocationService locationService;
  final bool showUserLocation;
  final bool showRouteLine;
  final double height;
  final double zoom;
  final double padding;

  const RestaurantMap({
    Key? key,
    required this.restaurant,
    required this.locationService,
    this.showUserLocation = true,
    this.showRouteLine = true,
    this.height = 250,
    this.zoom = 15.0,
    this.padding = 70.0,
  }) : super(key: key);

  @override
  State<RestaurantMap> createState() => _RestaurantMapState();
}

class _RestaurantMapState extends State<RestaurantMap> {
  late final MapController _mapController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adjustCameraPosition();
      setState(() => _initialized = true);
    });
  }

  void _adjustCameraPosition() {
    try {
      final restaurantPoint = LatLng(
        widget.restaurant.latitude,
        widget.restaurant.longitude,
      );

      if (widget.showUserLocation &&
          widget.locationService.hasValidPosition &&
          widget.locationService.userPosition != null) {
        final userPoint = LatLng(
          widget.locationService.userPosition!.latitude,
          widget.locationService.userPosition!.longitude,
        );

        final bounds = LatLngBounds.fromPoints([restaurantPoint, userPoint]);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: EdgeInsets.all(widget.padding),
          ),
        );
      } else {
        _mapController.move(restaurantPoint, widget.zoom);
      }
    } catch (e) {
      debugPrint('Error adjusting camera position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: _initialized
          ? FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(
            widget.restaurant.latitude,
            widget.restaurant.longitude,
          ),
          initialZoom: widget.zoom,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.sae_mobile',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  widget.restaurant.latitude,
                  widget.restaurant.longitude,
                ),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              if (widget.showUserLocation &&
                  widget.locationService.hasValidPosition &&
                  widget.locationService.userPosition != null)
                Marker(
                  point: LatLng(
                    widget.locationService.userPosition!.latitude,
                    widget.locationService.userPosition!.longitude,
                  ),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
            ],
          ),
          if (widget.showRouteLine &&
              widget.locationService.hasValidPosition &&
              widget.locationService.userPosition != null)
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
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}