import 'package:flutter/material.dart';
import 'package:sae_mobile/widgets/home.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
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
