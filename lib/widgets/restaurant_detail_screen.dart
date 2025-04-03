import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/models/review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/database/database_helper.dart';
import '../models/helper/auth_helper.dart';
import '../models/restaurant.dart';
import '../../Restaurant/restaurant_map.dart';

class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;
  static String? CURRENT_USER_ID = AuthHelper.getCurrentUser().id;

  const RestaurantDetailPage({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final TextEditingController _avisController = TextEditingController();
  final LocationService _locationService = LocationService();
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text("Restaurant introuvable")));
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
          aspectRatio: 16/9,
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
          Text(restaurant.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),

          // Section Informations générales
          _buildInfoRow("Lieu", "${restaurant.region}, ${restaurant.departement}"),
          if (restaurant.brand?.isNotEmpty ?? false)
            _buildInfoRow("Marque", restaurant.brand!),
          if (restaurant.opening_hours?.isNotEmpty ?? false)
            _buildInfoRow("Horaires", restaurant.opening_hours!),
          if (restaurant.phone?.isNotEmpty ?? false)
            _buildPhoneRow(restaurant.phone!),

          // Section Carte
          const SizedBox(height: 20),
          _buildMapSection(restaurant),

          // Section Services
          if (restaurant.hasServices)
            _buildServicesSection(restaurant),

          // Section Avis
          const Divider(height: 40),
          _buildReviewsSection(restaurant),
        ],
      ),
    );
  }

  Widget _buildMapSection(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Localisation', style: Theme.of(context).textTheme.titleLarge),
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
              'Distance: ${_locationService.calculateDistanceTo(
                  restaurant.latitude, restaurant.longitude)
                  ?.toStringAsFixed(1)} km',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(String phone) {
    return Row(
      children: [
        const Text("📞 ", style: TextStyle(fontSize: 20)),
        TextButton(
          onPressed: () => launchUrl(Uri.parse('tel:$phone')),
          child: Text(
            phone,
            style: const TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            if (restaurant.wheelchair) _buildServiceChip("Accès PMR"),
            if (restaurant.vegetarian) _buildServiceChip("Végétarien"),
            if (restaurant.vegan) _buildServiceChip("Végan"),
            if (restaurant.delivery) _buildServiceChip("Livraison"),
            if (restaurant.takeaway) _buildServiceChip("À emporter"),
            if (restaurant.internet_access) _buildServiceChip("Wi-Fi"),
            if (restaurant.drive_through) _buildServiceChip("Drive-through"),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceChip(String label) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
    );
  }

  Widget _buildReviewsSection(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (RestaurantDetailPage.CURRENT_USER_ID != null) ...[
          _buildReviewInput(),
          const SizedBox(height: 20),
        ],
        Text('Avis clients', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        FutureBuilder<List<Review>>(
          future: DatabaseHelper.getReviewsRestau(widget.restaurantId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            return _buildReviewList(snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Laisser un avis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: List.generate(
            5,
                (index) => IconButton(
              icon: Icon(
                index < _selectedRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => setState(() => _selectedRating = index + 1),
            ),
          ),
        ),
        TextField(
          controller: _avisController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Votre avis...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Publier l'avis"),
            onPressed: _submitReview,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewList(List<Review> avisList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: avisList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final avis = avisList[index];
        return Card(
          child: ListTile(
            title: Text("Utilisateur ${avis.userId}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(avis.avis),
                Text(
                  avis.date.toLocal().toString().split(' ')[0],
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                    (i) => Icon(
                  i < avis.etoiles ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitReview() async {
    if (_avisController.text.isEmpty) return;

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