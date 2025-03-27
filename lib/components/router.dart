import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/widgets/home.dart';
import 'package:sae_mobile/widgets/carte_screen.dart';
import 'package:sae_mobile/widgets/avis.dart';
import 'package:sae_mobile/widgets/restaurant_detail_screen.dart';
import '../components/database_helper.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return HomeScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Center(child: Text('Accueil')),
        ),
        GoRoute(
          path: '/favoris',
          builder: (context, state) => const Center(child: Text('Favoris')),
        ),
        GoRoute(
          path: '/carte',
          builder: (context, state) => Center(child: CarteScreen()),
        ),
        GoRoute(
          path: '/avis',
          builder: (context, state) => Center(child: AvisPage()),
        ),
        GoRoute(
          path: '/profil',
          builder: (context, state) => const Center(child: Text('Profil')),
        ),
        GoRoute(
          path: '/restaurant/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const Center(child: Text('ID de restaurant invalide.'));
            }
            return FutureBuilder(
              future: DatabaseHelper.getRestaurantById(id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Restaurant introuvable.'));
                }
                return RestaurantDetailPage(restaurantId: id);
              },
            );
          },
        ),
      ],
    ),
  ],
);
