import 'package:flutter/material.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen ({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen > {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpapers'),
      ),
      body: const Center(
        child: Text('Wallpapers Screen'),
      ),
    );
  }
}
