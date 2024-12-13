import 'package:flutter/material.dart';
import 'package:qr_app/screens/home_screen.dart';
import 'package:qr_app/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Get from storage
  final bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlmiAsistencias',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      home: _isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
