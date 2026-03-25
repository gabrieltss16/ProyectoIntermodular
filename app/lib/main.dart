import 'package:fisioia/screens/home_screen.dart';
import 'package:fisioia/screens/zones_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FisioIA',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}


