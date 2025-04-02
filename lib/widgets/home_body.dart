import 'package:flutter/material.dart';

import '../components/Restaurant/build_carousel.dart';

class HomeBodyScreen extends StatelessWidget {
  const HomeBodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          RestaurantCarousel(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}