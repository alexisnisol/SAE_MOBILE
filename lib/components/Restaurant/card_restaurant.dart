import 'package:flutter/material.dart';
import '../../models/database/database_helper.dart';
import '../../models/location_service.dart';
import '../../models/restaurant.dart';
import 'package:go_router/go_router.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final LocationService locationService;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.locationService,
  });

  @override
  Widget build(BuildContext context) {
    final distance = locationService.calculateDistanceTo(
      restaurant.latitude.toDouble(),
      restaurant.longitude.toDouble(),
    );

    return FutureBuilder<String>(
      future: DatabaseHelper.imageLink(restaurant.name),
      builder: (context, imageSnapshot) {
        final imageUrl = imageSnapshot.data ?? DatabaseHelper.DEFAULT_IMAGE;

        return GestureDetector(
          onTap: () => context.go('/restaurant/${restaurant.id_restaurant}'),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du restaurant
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SizedBox(
                    height: 135,
                    width: double.infinity,
                    child: imageSnapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 50),
                    ),
                  ),
                ),

                // Contenu texte
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.commune ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (distance != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                '${distance.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}