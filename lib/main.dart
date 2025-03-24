import 'package:flutter/material.dart';
import 'package:sae_mobile/components/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Taste&Tell',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
