import 'package:flutter/material.dart';

class QrScreen extends StatefulWidget {
  const QrScreen ({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
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
