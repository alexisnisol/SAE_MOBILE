import 'package:flutter/material.dart';
import '../../models/database/database_helper.dart';
import '../../models/location_service.dart';
import '../../models/restaurant.dart';

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
                  Container(
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
                    child:
                        imageSnapshot.connectionState == ConnectionState.waiting
                            ? const Center(child: CircularProgressIndicator())
                            : null,
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
                    if (distance != null &&
                        !locationService.isUsingDefaultLocation())
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km',
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
      },
    );
  }
}
