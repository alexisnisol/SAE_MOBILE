import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/location_service.dart';
import '../../models/restaurant.dart';

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
  late List<Marker> _markers;
  late List<Polyline> _polylines;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _markers = [];
    _polylines = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
      setState(() => _initialized = true);
    });
  }

  void _initializeMap() {
    debugPrint('Initializing map with restaurant at: '
        '${widget.restaurant.latitude}, ${widget.restaurant.longitude}');

    _updateMarkers();
    _updatePolylines();
    _adjustCameraPosition();
  }

  void _updateMarkers() {
    _markers = [];
    final restaurant = widget.restaurant;

    // Restaurant marker - plus visible avec un fond et une taille augmentée
    if (_isValidLatLng(restaurant.latitude, restaurant.longitude)) {
      _markers.add(
        Marker(
          point: LatLng(restaurant.latitude, restaurant.longitude),
          width: 50,
          height: 50,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 30),
          ),
        ),
      );
      debugPrint('Added restaurant marker');
    } else {
      debugPrint('Invalid restaurant coordinates: '
          '${restaurant.latitude}, ${restaurant.longitude}');
    }

    // User location marker
    if (widget.showUserLocation &&
        widget.locationService.hasValidPosition &&
        widget.locationService.userPosition != null) {
      final userPos = widget.locationService.userPosition!;
      if (_isValidLatLng(userPos.latitude, userPos.longitude)) {
        _markers.add(
          Marker(
            point: LatLng(userPos.latitude, userPos.longitude),
            width: 50,
            height: 50,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.person_pin, color: Colors.white, size: 30),
            ),
          ),
        );
        debugPrint('Added user location marker');
      }
    }
  }

  void _updatePolylines() {
    _polylines = [];

    if (widget.showRouteLine &&
        widget.locationService.hasValidPosition &&
        widget.locationService.userPosition != null &&
        _isValidLatLng(widget.restaurant.latitude, widget.restaurant.longitude)) {
      final userPos = widget.locationService.userPosition!;
      if (_isValidLatLng(userPos.latitude, userPos.longitude)) {
        _polylines.add(
          Polyline(
            points: [
              LatLng(userPos.latitude, userPos.longitude),
              LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
            ],
            color: Colors.blue.withOpacity(0.7),
            strokeWidth: 4, // Ligne plus épaisse
          ),
        );
        debugPrint('Added route polyline');
      }
    }
  }

  void _adjustCameraPosition() {
    try {
      final restaurantPoint = LatLng(
        widget.restaurant.latitude,
        widget.restaurant.longitude,
      );

      if (!_isValidLatLng(restaurantPoint.latitude, restaurantPoint.longitude)) {
        debugPrint('Invalid restaurant coordinates, cannot adjust camera');
        return;
      }

      if (widget.showUserLocation &&
          widget.locationService.hasValidPosition &&
          widget.locationService.userPosition != null) {
        final userPoint = LatLng(
          widget.locationService.userPosition!.latitude,
          widget.locationService.userPosition!.longitude,
        );

        if (_isValidLatLng(userPoint.latitude, userPoint.longitude)) {
          final bounds = LatLngBounds.fromPoints([restaurantPoint, userPoint]);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: EdgeInsets.all(widget.padding),
            ),
          );
          debugPrint('Camera adjusted to show both restaurant and user location');
          return;
        }
      }

      _mapController.move(restaurantPoint, widget.zoom);
      debugPrint('Camera centered on restaurant at zoom ${widget.zoom}');
    } catch (e) {
      debugPrint('Error adjusting camera position: $e');
    }
  }

  bool _isValidLatLng(double latitude, double longitude) {
    final isValid = latitude.abs() <= 90 && longitude.abs() <= 180;
    if (!isValid) {
      debugPrint('Invalid coordinates: latitude=$latitude, longitude=$longitude');
    }
    return isValid;
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
          PolylineLayer(polylines: _polylines),
          MarkerLayer(
            markers: _markers,
            rotate: false,
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