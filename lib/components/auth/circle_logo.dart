import 'package:flutter/material.dart';

class CircleLogo extends CircleAvatar {
  CircleLogo({super.key})
      : super(
          radius: 48,
          backgroundImage: Image.asset("assets/images/logo.jpg").image,
        );
}
