import 'package:flutter/material.dart';
import 'package:qr_app/screens/absences_screen.dart';
import 'package:qr_app/screens/assistances_screen.dart';
import 'package:qr_app/screens/login_screen.dart';
import 'package:qr_app/screens/qr_screen.dart';
import 'package:qr_app/widgets/option_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue.shade600,
          centerTitle: true,
          title: const Text('Inicio', style: TextStyle(color: Colors.white))),
      body: Center(
          child: SizedBox(
              width: 350,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AbsencesScreen()));
                      },
                      child: const OptionCard(
                        icon: Icons.access_time_filled,
                        title: 'Faltas',
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AssistancesScreen()));
                      },
                      child: const OptionCard(
                        icon: Icons.view_list,
                        title: 'Asistencias',
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const QrScreen()));
                      },
                      child: const OptionCard(
                        icon: Icons.qr_code_2,
                        title: 'Lector QR',
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                      },
                      child: const OptionCard(
                        icon: Icons.vpn_key_off,
                        title: 'Cerrar Sesion',
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }
}
