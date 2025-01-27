import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ip_country_lookup/models/ip_country_data_model.dart';
import 'package:qr_app/screens/home_screen.dart';
import 'package:qr_app/services/graphql_service.dart';
import 'package:qr_app/services/localstore_service.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:ip_country_lookup/ip_country_lookup.dart';

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  State<NfcScreen> createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? result;
  final GraphQLService graphQLService = GraphQLService();
  final LocalStoreService localStoreService = LocalStoreService();
  String _scannedCode = 'No code scanned yet';
  bool _isScannerPaused = false;

  @override
  void dispose() {
    // Always dispose the controller when not in use
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => startNFCLoop());
  }

  void startNFCLoop() async {
    if (await FlutterNfcKit.nfcAvailability != NFCAvailability.available) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomeScreen()));
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Mensaje'),
            content: const Text("La lectura NFC no esta disponible"),
            actions: <Widget>[
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    while (true) {
      if (!_isScannerPaused) {
        var tag = await FlutterNfcKit.poll(
            timeout: const Duration(seconds: 10),
            iosMultipleTagMessage: "Mas de una tag encontrada",
            iosAlertMessage: "Escanea tu tag");
        var data = tag.toJson();
        dynamic resp = null;
        if (data['tipo'] == 'entrada') {
          resp = await graphQLService.performMutation(r'''
			mutation RegistrarEntradaCurso($registrarEntradaCursoStudentId2: ID!, $courseCode: String!, $ubicacion: String!, $ip: String!, $mac: String!) {
			  registrarEntradaCurso(studentId: $registrarEntradaCursoStudentId2, courseCode: $courseCode, ubicacion: $ubicacion, ip: $ip, mac: $mac) {
				id
			  }
			}
	  ''', variables: {
            "registrarEntradaCursoStudentId2": graphQLService.userId,
            "courseCode": data['codigo'],
            "ubicacion": await _getCountry(),
            "ip": await IpCountryLookup().getUserIpAddress(),
            "mac": await NetworkInfo().getWifiBSSID()
          }, refreshTokenIfNeeded: false);

          await localStoreService.saveDocument(
              collection: 'asistencias',
              documentId: 'entrada',
              data: {'id': resp.data?['registrarEntradaCurso']['id']});
          // _showScannedCodeDialog('Entrada registrada');
        } else if (data['tipo'] == 'salida') {
          dynamic entrada = await localStoreService.getDocument(
              collection: 'asistencias', documentId: 'entrada');
          resp = await graphQLService.performMutation(r'''
		  	mutation RegistrarSalidaCurso($attendanceId: ID!, $registrarSalidaCursoUbicacion2: String!, $registrarSalidaCursoIp2: String!, $registrarSalidaCursoMac2: String!) {
			  registrarSalidaCurso(attendanceId: $attendanceId, ubicacion: $registrarSalidaCursoUbicacion2, ip: $registrarSalidaCursoIp2, mac: $registrarSalidaCursoMac2) {
				id
			  }
			}
		  ''', variables: {
            'attendanceId': entrada?['id'],
            "registrarSalidaCursoUbicacion2": await _getCountry(),
            "registrarSalidaCursoIp2":
                await IpCountryLookup().getUserIpAddress(),
            "registrarSalidaCursoMac2": await NetworkInfo().getWifiBSSID()
          }, refreshTokenIfNeeded: false);
          // _showScannedCodeDialog('Salida registrada');
        }
      }
    }
  }

  Future<String> _getCountry() async {
    IpCountryData lookup = await IpCountryLookup().getIpLocationData();
    return lookup.country_name.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        iconTheme: Theme.of(context).iconTheme,
        title: const Text('Lector NFC', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isScannerPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                if (_isScannerPaused) {
                  _isScannerPaused = false;
                } else {
                  _isScannerPaused = true;
                }
              });
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Center(
                    child: Text('Leyendo NFC cada 10 segundos',
                        style: TextStyle(color: Colors.grey))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
