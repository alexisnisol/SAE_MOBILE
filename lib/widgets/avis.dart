import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/components/review.dart';


class AvisPage extends StatefulWidget {
  const AvisPage({super.key});

  @override
  State<AvisPage> createState() => _AvisPageState();
}

class _AvisPageState extends State<AvisPage> {
  // Liste d'avis simulée (pour tous les utilisateurs pour l'instant)
  List<Review> reviews = [
    Review(
      id: '1',
      restaurantId: 'r1',
      restaurantName: 'Le Gourmet',
      userName: 'Alice',
      comment: 'Super ambiance et plats délicieux !',
    ),
    Review(
      id: '2',
      restaurantId: 'r2',
      restaurantName: 'Chez Bob',
      userName: 'Bob',
      comment: 'Bon rapport qualité/prix, service sympa.',
    ),
    Review(
      id: '3',
      restaurantId: 'r3',
      restaurantName: 'La Table de Charlie',
      userName: 'Charlie',
      comment: 'Le dessert était exceptionnel !',
    ),
  ];

  // Méthode pour supprimer un avis
  void _deleteReview(String id) {
    setState(() {
      reviews.removeWhere((review) => review.id == id);
    });
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
        centerTitle : true,

      ),
      body: reviews.isEmpty
          ? const Center(child: Text("Aucun avis pour le moment."))
          : ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                review.comment,
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Restaurant: ${review.restaurantName}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteReview(review.id),
              ),
              onTap: () {
                // Navigue vers la page du restaurant correspondant.
                context.go('/restaurant/${review.restaurantId}');
              },
            ),
          );
        },
      ),
    );
  }
}
