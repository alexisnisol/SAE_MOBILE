import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSection extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: restaurants.map((restaurant) {
      }).toList(),
      options: CarouselOptions(
        viewportFraction: 0.7,
        aspectRatio: 1.3,
        enableInfiniteScroll: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
