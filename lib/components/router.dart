import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/models/auth_helper.dart';
import 'package:sae_mobile/widgets/auth/login.dart';
import 'package:sae_mobile/widgets/avis.dart';
import 'package:sae_mobile/widgets/carte_screen.dart';
import 'package:sae_mobile/widgets/home.dart';
import '../widgets/auth/register.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        if (!AuthHelper.isSignedIn()) {
          return child;
        }
        return HomeScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Center(child: Text('Accueil')),
          redirect: (context, state) {
            if (!AuthHelper.isSignedIn()) {
              return '/login';
            }
            return null;
          },
        ),
        GoRoute(
          path: '/favoris',
          builder: (context, state) => const Center(child: Text('Favoris')),
          redirect: (context, state) {
            if (!AuthHelper.isSignedIn()) {
              return '/login';
            }
            return null;
          },
        ),
        GoRoute(
          path: '/carte',
          builder: (context, state) =>  Center(child: CarteScreen()),
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
          },
        )
      ],
    )
  ]
);
