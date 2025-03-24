import 'package:flutter/material.dart';
import '../components/Restaurant/restaurantCarousel.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

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