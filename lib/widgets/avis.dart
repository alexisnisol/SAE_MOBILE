import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/components/review.dart';
import '../components/database_helper.dart';
import 'package:sae_mobile/components/restaurant.dart';

class AvisPage extends StatefulWidget {
  const AvisPage({super.key});

  @override
  State<AvisPage> createState() => _AvisPageState();
}

class _AvisPageState extends State<AvisPage> {
  late Future<List<Review>> futureReviews;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    setState(() {
      futureReviews = DatabaseHelper.getReviews(1);
    });
  }

  Future<void> _deleteReview(int id) async {
    await DatabaseHelper.deleteReview(id);
    _loadReviews(); // Recharge la liste après suppression
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Avis',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xff587C60),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Review>>(
        future: futureReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun avis pour le moment."));
          } else {
            final reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];

                return FutureBuilder<Restaurant>(
                  future: DatabaseHelper.getRestaurantById(review.restaurantId),
                  builder: (context, restaurantSnapshot) {
                    if (!restaurantSnapshot.hasData) {
                      return const SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final restaurant = restaurantSnapshot.data!;

                    return FutureBuilder<String>(
                      future: DatabaseHelper.imageLink(restaurant.name), // Correction ici
                      builder: (context, imageSnapshot) {
                        String? imageUrl = imageSnapshot.data;
                        bool imageLoaded =
                            imageSnapshot.connectionState == ConnectionState.done && imageUrl != null;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: imageLoaded
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl!,
                                width: 65,
                                height: 75,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/default_restaurant.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            )
                                : const SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            title: Text(
                              review.avis,
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStarRating(review.etoiles),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Date : ${review.date.day}/${review.date.month}/${review.date.year}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteReview(review.id),
                            ),
                            onTap: () {
                              context.go('/restaurant/${review.restaurantId}');
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
