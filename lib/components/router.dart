import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/models/auth_helper.dart';
import 'package:sae_mobile/widgets/auth/login.dart';
import 'package:sae_mobile/widgets/avis.dart';
import 'package:sae_mobile/widgets/home_body.dart';
import 'package:sae_mobile/widgets/restaurant_detail_screen.dart';
import '../models/database/database_helper.dart';
import '../widgets/favoris.dart';

import 'package:sae_mobile/widgets/carte_screen.dart';
import 'package:sae_mobile/widgets/home.dart';
import '../widgets/auth/register.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        // Désactive la navigation dans les menu d'authentification
        if (!AuthHelper.isSignedIn()) {
          return child;
        }
        return HomeScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomeBodyScreen(),
          redirect: (context, state) {
            if (!AuthHelper.isSignedIn()) {
              return '/login';
            }
            return null;
          },
        ),
        GoRoute(
          path: '/favoris',
          builder: (context, state) => Center( child: GroupedFavorisPage()),
          redirect: (context, state) {
            if (!AuthHelper.isSignedIn()) {
              return '/login';
            }
            return null;
          },
        ),
        GoRoute(
          path: '/carte',
          builder: (context, state) => Center(child: CarteScreen()),
          redirect: (context, state) {
            if (!AuthHelper.isSignedIn()) {
              return '/login';
            }
            return null;
          },
        ),
        GoRoute(
          path: '/avis',
          builder: (context, state) =>  Center(child: AvisPage()),
          redirect: (context, state) {
            if (!AuthHelper.isSignedIn()) {
              return '/login';
            }
            return null;
          },
        ),
        GoRoute(
          path: '/profil',
          builder: (context, state) => const Center(child: Text('Profil')),
          redirect: (context, state) {
            if (!AuthHelper.isSignedIn()) {
              return '/login';
            }
            return null;
          },
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
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterScreen()
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/logout',
          redirect: (context, state) async {
            if(AuthHelper.isSignedIn()) {
              await AuthHelper.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Déconnexion réussie")),
              );
            }
            return '/login';
          }
        )
      ],
    )
  ]
);