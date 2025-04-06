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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review),
            label: 'Avis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

}
