import 'package:flutter/material.dart';
import 'package:qr_app/screens/home_screen.dart';
import 'package:qr_app/screens/login_screen.dart';
import 'package:qr_app/services/localstore_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final localStoreService = LocalStoreService();

  bool _isLoggedIn = false;

  void initState() async {
    final String? token = await getToken();
	_isLoggedIn = token != null ? true : false;
  }

  Future<String?> getToken() async {
    final user = await localStoreService.getDocument(
        collection: 'login', documentId: 'saved');
	if(user == null) return null;
    String token = user['token'];
    return token;
  }

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
