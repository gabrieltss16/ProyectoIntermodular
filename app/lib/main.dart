import 'package:fisioia/screens/home_screen.dart';
import 'package:flutter/material.dart';

import 'services/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.tryInit();
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


