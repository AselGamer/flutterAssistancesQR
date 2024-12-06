import 'package:flutter/material.dart';
import 'package:qr_app/models/assistance.dart';

class AssistancesScreen extends StatefulWidget {
  const AssistancesScreen ({super.key});

  @override
  State<AssistancesScreen> createState() => _AssistancesScreenState();
}

class _AssistancesScreenState extends State<AssistancesScreen> {
  final List<Assistance> absences = [
    Assistance(date: '2023-04-15', time: '9:30 AM'),
    Assistance(date: '2023-04-20', time: '1:15 PM'),
    Assistance(date: '2023-04-28', time: '11:00 AM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        iconTheme: Theme.of(context).iconTheme,
        title: const Text('Asistencias', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.separated(
        itemCount: absences.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final absence = absences[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${absence.date}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Hora: ${absence.time}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );
  }
}
