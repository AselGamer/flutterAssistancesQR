import 'package:flutter/material.dart';
import 'package:qr_app/screens/home_screen.dart';
import 'package:qr_app/services/graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:qr_app/services/localstore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final localStoreService = LocalStoreService();
  final GraphQLService graphQLService = GraphQLService();

  String _message = '';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /* _testQuery() async {
    QueryResult resp = await graphQLService.performQuery(r'''
		query ObtenerAlumno {
			obtenerAlumno(id: "d7287f62-eb33-4c3e-b6b3-a0f619032e6b") {
				id
				nombre
				email
				password
				curso
			}
		}
        ''', variables: {
    }, refreshTokenIfNeeded: false);

	print(resp.data?['obtenerAlumno']['id']);
  } */

  _attemptLogin() async {
    // print(emailController.text);
    // print(passwordController.text);
    QueryResult resp = await graphQLService.performMutation(r'''
		mutation IniciarSesion($email: String!, $password: String!) {
        	iniciarSesion(
				email: $email,
				password: $password
			)
			{
				token
				student {
					id
				}
			}
		}
        ''', variables: {
      'email': emailController.text,
      'password': passwordController.text,
    }, refreshTokenIfNeeded: false);
    // print(resp.data);
    // print(resp.data?['iniciarSesion']['token']);
    if (resp.data?['iniciarSesion']['token'] != null) {
      setState(() {
        _message = '';
      });
      _storeLogin(resp.data?['iniciarSesion']['token']);
	  graphQLService.userId = resp.data?['iniciarSesion']['student']['id'];
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      setState(() {
        _message = 'Fallo al inciar sesion.';
      });
    }
  }

  _storeLogin(token) async {
    // Change for the one in GraphqlService
    /* await localStoreService.saveDocument(
        collection: 'login', documentId: 'saved', data: {'token': token}); */
    await graphQLService.updateToken(token);
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.blue.shade600,
            iconTheme: Theme.of(context).iconTheme,
            title: const Text('Inicio de sesion',
                style: TextStyle(color: Colors.white)),
            automaticallyImplyLeading: false,
          ),
          body: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade300, Colors.blue.shade800],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _attemptLogin(),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              SizedBox(height: _message != '' ? 20 : 0),
                              Text(_message,
                                  style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
