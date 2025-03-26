import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/widgets/home.dart';
import 'package:sae_mobile/widgets/carte_screen.dart';
import 'package:sae_mobile/widgets/avis.dart';
import '../widgets/homeBody.dart';

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
          builder: (context, state) => const HomeBody(),
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
      ],
    ),
  ],
);
