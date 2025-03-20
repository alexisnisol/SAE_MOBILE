import 'package:flutter/material.dart';
import 'package:sae_mobile/widgets/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taste&Tell',
      home : const Home(),
      debugShowCheckedModeBanner: false,


    );
  }
}
