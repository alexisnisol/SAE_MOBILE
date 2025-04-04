import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  int _getIndexFromRoute(BuildContext context) {
    final currentLocation = GoRouter.of(context).state.uri.path;
    switch (currentLocation) {
      case '/': return 0;
      case '/favoris': return 1;
      case '/carte': return 2;
      case '/avis': return 3;
      case '/profil': return 4;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getIndexFromRoute(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/favoris'); break;
            case 2: context.go('/carte'); break;
            case 3: context.go('/avis'); break;
            case 4: context.go('/profil'); break;
          }
        },
        selectedItemColor: Colors.green, // Couleur verte pour l'élément sélectionné
        unselectedItemColor: Colors.black, // Couleur noire pour les éléments non sélectionnés
        selectedLabelStyle: TextStyle(color: Colors.green), // Texte vert pour l'élément sélectionné
        unselectedLabelStyle: TextStyle(color: Colors.black), // Texte noir pour les autres
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: selectedIndex == 0 ? Colors.green : Colors.black),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star, color: selectedIndex == 1 ? Colors.green : Colors.black),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: selectedIndex == 2 ? Colors.green : Colors.black),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review, color: selectedIndex == 3 ? Colors.green : Colors.black),
            label: 'Avis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: selectedIndex == 4 ? Colors.green : Colors.black),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}