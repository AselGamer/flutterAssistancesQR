import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qr_app/models/assistance.dart';
import 'package:intl/intl.dart';
import 'package:qr_app/services/graphql_service.dart';

class AssistancesScreen extends StatefulWidget {
  const AssistancesScreen({super.key});

  @override
  State<AssistancesScreen> createState() => _AssistancesScreenState();
}

class _AssistancesScreenState extends State<AssistancesScreen> {
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat timerFormatter = DateFormat('hh:mm a');
  final GraphQLService graphQLService = GraphQLService();

  List<Assistance> assitances = [
    /* Assistance(date: '2023-04-15', time: '9:30 AM'),
    Assistance(date: '2023-04-20', time: '1:15 PM'),
    Assistance(date: '2023-04-28', time: '11:00 AM'), */
  ];

  _fillAssitances() async {
    // print(graphQLService.userId);
    QueryResult resp = await graphQLService.performQuery(r'''
	query ObtenerAsistencias($obtenerAsistenciasStudentId2: ID!) {
			obtenerAsistencias(studentId: $obtenerAsistenciasStudentId2) {
				id
				courseCode
				entradaFecha
				salidaFecha
				totalHoras
		  }
	  }
	''',
        variables: {"obtenerAsistenciasStudentId2": graphQLService.userId},
        refreshTokenIfNeeded: false);

    // print(resp.data?['obtenerAsistencias']);
    List<dynamic> respArray = resp.data?['obtenerAsistencias'].map((item) {
      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }
      throw ArgumentError('Item is not a map');
    }).toList();

    List<Assistance> tempAssistances = [];
    int assitLength = respArray.length;
    for (var i = 0; i < assitLength; i++) {
      Assistance tempAssit = Assistance(
        id: respArray[i]?['id'],
        courseCode: (respArray[i]?['courseCode']),
        entradaFecha: DateTime.parse(respArray[i]?['entradaFecha']),
      );
      tempAssistances.add(tempAssit);
    }
    setState(() {
      assitances = tempAssistances;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This runs after the first frame is drawn
      _fillAssitances();
    });
  }

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
        itemCount: assitances.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final absence = assitances[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Fecha entrada: ${dateFormatter.format(absence.entradaFecha)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      'Hora entrada: ${timerFormatter.format(absence.entradaFecha)}',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('Curso: ${absence.courseCode}',
                      style: const TextStyle(fontSize: 14)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
