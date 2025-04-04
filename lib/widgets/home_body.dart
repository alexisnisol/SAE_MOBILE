import 'package:flutter/material.dart';
import 'package:sae_mobile/models/helper/auth_helper.dart';
import 'package:sae_mobile/models/database/database_helper.dart';
import 'package:sae_mobile/models/restaurant.dart';

import '../components/Restaurant/build_carousel.dart';

class HomeBodyScreen extends StatefulWidget {
  const HomeBodyScreen({super.key});

  @override
  State<HomeBodyScreen> createState() => _HomeBodyScreenState();
}

class _HomeBodyScreenState extends State<HomeBodyScreen> {
  late Future<List<Restaurant>> _userLikedRestaurants; // Change type to List<Restaurant>
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _userLikedRestaurants = _fetchLikedRestaurants();
  }

  Future<List<Restaurant>> _fetchLikedRestaurants() async {
    final userId = AuthHelper.getCurrentUser()?.id;
    if (userId == null) return [];
    return await DatabaseHelper.getUserLikedRestaurants(userId);
  }

  Future<void> _handleRefresh() async {
    setState(() => _loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const RestaurantCarousel(title: 'Nos restaurants'),
            const SizedBox(height: 24),
            _buildProximityCarousel(),
            const SizedBox(height: 24),
            _buildLikedRestaurantsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProximityCarousel() => RestaurantCarousel(
    title: 'Restaurants près de chez vous',
    filter: (restaurant, locationService) {
      final distance = locationService.calculateDistanceTo(
        restaurant.latitude.toDouble(),
        restaurant.longitude.toDouble(),
      );
      return distance != null && distance < 5;
    },
  );

  Widget _buildLikedRestaurantsSection() => FutureBuilder<List<Restaurant>>(
    future: _userLikedRestaurants, // Change the type to List<Restaurant>
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingSection();
      }

      final likedRestaurants = snapshot.data ?? [];
      final hasLikes = likedRestaurants.isNotEmpty;

      return Column(
        children: [
          RestaurantCarousel(
            title: 'Vos restaurants likés',
            filter: (restaurant, _) => likedRestaurants.contains(restaurant),
          ),
          if (!hasLikes) _buildRestaurantDiscoveryPrompt(),
        ],
      );
    },
  );

  Widget _buildLoadingSection() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _buildLoginPrompt() => Column(
    children: [
      const Text('Connectez-vous pour voir vos restaurants likés'),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        child: const Text('Se connecter'),
      ),
    ],
  );

  Widget _buildRestaurantDiscoveryPrompt() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Commencez à liker des restaurants !',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Likez vos restaurants préférés dans leurs fiches détaillées pour les retrouver ici',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ),
  );
}
