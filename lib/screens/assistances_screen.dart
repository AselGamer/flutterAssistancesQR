import 'package:flutter/material.dart';

class AssistancesScreen extends StatefulWidget {
  const AssistancesScreen ({super.key});

  @override
  State<AssistancesScreen> createState() => _AssistancesScreenState();
}

class _AssistancesScreenState extends State<AssistancesScreen> {
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
