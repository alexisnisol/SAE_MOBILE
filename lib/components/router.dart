import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/widgets/auth/login.dart';
import 'package:sae_mobile/widgets/home.dart';
import 'package:sae_mobile/widgets/carte_screen.dart';
import 'package:sae_mobile/widgets/avis.dart';


import '../widgets/auth/register.dart';

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
          builder: (context, state) =>  Center(child: CarteScreen()),
        ),
        GoRoute(
          path: '/avis',
          builder: (context, state) =>  Center(child: AvisPage()),
        ),
        GoRoute(
          path: '/profil',
          builder: (context, state) => const Center(child: Text('Profil')),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterScreen()
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen()
        ),
      ],
    ),
);
