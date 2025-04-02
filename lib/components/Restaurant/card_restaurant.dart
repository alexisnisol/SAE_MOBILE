import 'package:flutter/material.dart';
import '../../models/database/database_helper.dart';
import '../../models/restaurant.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final Position? userPosition;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.userPosition,
  });

  double? _calculateDistance() {
    if (userPosition == null) return null;

    return Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      restaurant.latitude as double,
      restaurant.longitude as double,
    ) / 1000;
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();

    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              FutureBuilder<String>(
                future: DatabaseHelper.imageLink(restaurant.name),
                builder: (context, snapshot) {
                  final imageUrl = snapshot.data ?? DatabaseHelper.DEFAULT_IMAGE;
                  return Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                  );
                },
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                  size: 28,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  restaurant.commune,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      distance != null
                          ? '${distance.toStringAsFixed(1)} km'
                          : 'Distance inconnue',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}