import 'package:flutter/material.dart';
import 'title_section.dart';
import 'carousel_section.dart';

class RestaurantCarousel extends StatelessWidget {
  final List<Map<String, String>> restaurants = [
    {"name": "Le Gourmet", "rating": "4.5", "cuisine": "Française"},
    {"name": "Chez Marie", "rating": "4.7", "cuisine": "Italienne"},
    {"name": "L'Épicurien", "rating": "4.2", "cuisine": "Espagnole"},
    {"name": "Bistro 42", "rating": "4.8", "cuisine": "Américaine"},
    {"name": "Le Petit Chef", "rating": "4.6", "cuisine": "Indienne"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleSection(),
        CarouselSection(restaurants: restaurants),
      ],
    );
  }
}