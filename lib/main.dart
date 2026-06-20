import 'package:flutter/material.dart';
import 'features/authentication/presentation/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My MBG Gue',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
