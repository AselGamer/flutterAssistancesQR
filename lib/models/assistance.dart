class Assistance {
  final String id;
  final String courseCode;
  final DateTime entradaFecha;
  final DateTime? salidaFecha;
  // final String entradaUbicacion;
  // final String? salidaUbicacion;
  // final String entradaIP;
  // final String? salidaIP;
  // final String entradaMAC;
  // final String? salidaMAC;
  final String? totalHoras;

  Assistance({
    required this.id,
    required this.courseCode,
    required this.entradaFecha,
    this.salidaFecha,
    // required this.entradaUbicacion,
    // required this.salidaUbicacion,
    // required this.entradaIP,
    // required this.salidaIP,
    // required this.entradaMAC,
    // required this.salidaMAC,
    this.totalHoras,
  });
}
