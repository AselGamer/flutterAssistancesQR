import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qr_app/models/absence.dart';
import 'package:qr_app/services/graphql_service.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat timerFormatter = DateFormat('hh:mm a');
  final GraphQLService graphQLService = GraphQLService();

  List<Absence> absences = [
    /* Absence(date: '2023-04-15', time: '9:30 AM', teacher: 'Mrs. Smith'),
    Absence(date: '2023-04-20', time: '1:15 PM', teacher: 'Mr. Jones'),
    Absence(date: '2023-04-28', time: '11:00 AM', teacher: 'Ms. Johnson'), */
  ];

  _fillAbsences() async {
    QueryResult resp = await graphQLService.performQuery(r'''
	query Query($obtenerFaltasPorEstudianteStudentId2: ID!) {
	  obtenerFaltasPorEstudiante(studentId: $obtenerFaltasPorEstudianteStudentId2) {
		id
		studentid
		fecha
	  }
	}
	''',
        variables: {"obtenerFaltasPorEstudianteStudentId2": graphQLService.userId},
        refreshTokenIfNeeded: false);

    List<dynamic> respArray = resp.data?['obtenerFaltasPorEstudiante'].map((item) {
      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }
      throw ArgumentError('Item is not a map');
    }).toList();

    List<Absence> tempAbsences = [];
    int assitLength = respArray.length;
    for (var i = 0; i < assitLength; i++) {
      Absence tempAssit = Absence(
        id: respArray[i]?['id'],
        datetime: DateTime.parse(respArray[i]?['fecha']),
      );
      tempAbsences.add(tempAssit);
    }
    setState(() {
      absences = tempAbsences;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This runs after the first frame is drawn
      _fillAbsences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        iconTheme: Theme.of(context).iconTheme,
        title: const Text('Faltas', style: TextStyle(color: Colors.white)),
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
                Text('Fecha: ${dateFormatter.format(absence.datetime)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Hora: ${timerFormatter.format(absence.datetime)}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );
  }
}
