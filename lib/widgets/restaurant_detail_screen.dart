import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/models/review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/Restaurant/RestaurantMap.dart';
import '../models/database/database_helper.dart';
import '../models/helper/auth_helper.dart';
import '../models/location_service.dart';
import '../models/restaurant.dart';

class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;
  static String? CURRENT_USER_ID = AuthHelper.getCurrentUser().id;

  const RestaurantDetailPage({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final LocationService _locationService = LocationService();
  final TextEditingController _avisController = TextEditingController();
  Map<int, bool> likedCuisines = {};
  int _selectedRating = 3;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
    _locationService.getUserLocation(false);
  }

  Future<void> _checkIfFavorited() async {
    if (RestaurantDetailPage.CURRENT_USER_ID != null) {
      bool favorited = await DatabaseHelper.isRestaurantFavorited(
          RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId);
      setState(() => _isFavorited = favorited);
    }
  }

  Future<void> _toggleFavorite() async {
    if (RestaurantDetailPage.CURRENT_USER_ID == null) return;

    _isFavorited
        ? await DatabaseHelper.deleteRestaurantFavoris(
        RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId)
        : await DatabaseHelper.addRestaurantFavoris(
        RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId);
    _checkIfFavorited();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Restaurant>(
      future: DatabaseHelper.getRestaurantById(widget.restaurantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Restaurant introuvable.")),
          );
        }

        final restaurant = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/carte'),
            ),
            title: Text(restaurant.name),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildRestaurantImage(restaurant),
                _buildRestaurantInfo(restaurant),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantImage(Restaurant restaurant) {
    return FutureBuilder<String>(
      future: DatabaseHelper.imageLink(restaurant.name),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data ?? DatabaseHelper.DEFAULT_IMAGE;
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.restaurant, size: 50),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantInfo(Restaurant restaurant) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 20),
          _buildLocationInfo(restaurant),
          const SizedBox(height: 20),
          _buildContactInfo(restaurant),
          const SizedBox(height: 20),
          _buildMapSection(restaurant),
          const SizedBox(height: 20),
          _buildServicesSection(restaurant),
          const SizedBox(height: 20),
          _buildReviewsSection(restaurant),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localisation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${restaurant.commune}, ${restaurant.departement}, ${restaurant.region}',
          style: const TextStyle(fontSize: 16),
        ),
        if (restaurant.opening_hours?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Horaires : ${restaurant.opening_hours}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildContactInfo(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (restaurant.phone?.isNotEmpty ?? false)
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(restaurant.phone!),
            onTap: () => launchUrl(Uri.parse('tel:${restaurant.phone}')),
          ),
        if (restaurant.website?.isNotEmpty ?? false)
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(restaurant.website!),
            onTap: () => launchUrl(Uri.parse(restaurant.website!)),
          ),
      ],
    );
  }

  Widget _buildMapSection(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sur la carte',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        RestaurantMap(
          restaurant: restaurant,
          locationService: _locationService,
          height: 250,
        ),
        if (_locationService.hasValidPosition)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'À ${_locationService.calculateDistanceTo(restaurant.latitude, restaurant.longitude)?.toStringAsFixed(1)} km',
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildServicesSection(Restaurant restaurant) {
    final services = [
      if (restaurant.wheelchair) 'Accès PMR',
      if (restaurant.vegetarian) 'Végétarien',
      if (restaurant.vegan) 'Végan',
      if (restaurant.delivery) 'Livraison',
      if (restaurant.takeaway) 'À emporter',
      if (restaurant.drive_through) 'Drive-through',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services
              .map((service) => Chip(
            label: Text(service),
            avatar: const Icon(Icons.check_circle, size: 18),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (RestaurantDetailPage.CURRENT_USER_ID != null)
          _buildReviewInputSection(),
        const SizedBox(height: 20),
        FutureBuilder<List<Review>>(
          future: DatabaseHelper.getReviewsRestau(widget.restaurantId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildReviewList(snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildReviewInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laisser un avis',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            5,
                (index) => IconButton(
              icon: Icon(
                index < _selectedRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 30,
              ),
              onPressed: () => setState(() => _selectedRating = index + 1),
            ),
          ),
        ),
        TextField(
          controller: _avisController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Écrivez votre avis...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Publier'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewList(List<Review> reviews) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const Divider(height: 30),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Utilisateur ${review.userId}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(review.avis),
              const SizedBox(height: 5),
              Text(
                '${review.date.day}/${review.date.month}/${review.date.year}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
                  (i) => Icon(
                i < review.etoiles ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitReview() async {
    if (_avisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez écrire un avis')),
      );
      return;
    }

    await DatabaseHelper.addReview(
      RestaurantDetailPage.CURRENT_USER_ID!,
      widget.restaurantId,
      _avisController.text,
      _selectedRating,
      DateTime.now(),
    );

    setState(() {
      _avisController.clear();
      _selectedRating = 3;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avis publié avec succès !')),
    );
  }
}