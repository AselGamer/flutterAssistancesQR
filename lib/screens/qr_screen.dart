import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ip_country_lookup/models/ip_country_data_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_app/services/graphql_service.dart';
import 'package:qr_app/services/localstore_service.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ip_country_lookup/ip_country_lookup.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? result;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );
  final GraphQLService graphQLService = GraphQLService();
  final LocalStoreService localStoreService = LocalStoreService();
  String _scannedCode = 'No code scanned yet';
  bool _isScannerPaused = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    // Always dispose the controller when not in use
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final Barcode barcode = barcodes.first;

      setState(() {
        _scannedCode = barcode.rawValue ?? 'No data';
        _isScannerPaused = true;
      });

      if (_scannedCode != 'No data') {
        Map<String, dynamic> qrData = jsonDecode(_scannedCode);
        dynamic resp = null;
        if (qrData['tipo'] == 'entrada') {
          resp = await graphQLService.performMutation(r'''
			mutation RegistrarEntradaCurso($registrarEntradaCursoStudentId2: ID!, $courseCode: String!, $ubicacion: String!, $ip: String!, $mac: String!) {
			  registrarEntradaCurso(studentId: $registrarEntradaCursoStudentId2, courseCode: $courseCode, ubicacion: $ubicacion, ip: $ip, mac: $mac) {
				id
			  }
			}
	  ''', variables: {
            "registrarEntradaCursoStudentId2": graphQLService.userId,
            "courseCode": qrData['codigo'],
            "ubicacion": await _getCountry(),
            "ip": await IpCountryLookup().getUserIpAddress(),
            "mac": await NetworkInfo().getWifiBSSID()
          }, refreshTokenIfNeeded: false);

          await localStoreService.saveDocument(
              collection: 'asistencias',
              documentId: 'entrada',
              data: {'id': resp.data?['registrarEntradaCurso']['id']});
          _showScannedCodeDialog('Entrada registrada');
        } else if (qrData['tipo'] == 'salida') {
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
          _showScannedCodeDialog('Salida registrada');
        }
      }

      // Optional: Show a dialog with the scanned code
      // _showScannedCodeDialog(barcode.rawValue);
    }
  }

  Future<String> _getCountry() async {
    IpCountryData lookup = await IpCountryLookup().getIpLocationData();
    return lookup.country_name.toString();
  }

  void _showScannedCodeDialog(String? code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mensaje'),
          content: Text(code ?? 'No data'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
                // Resume scanning
                setState(() {
                  _isScannerPaused = false;
                  _scannerController.start();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        iconTheme: Theme.of(context).iconTheme,
        title: const Text('Lector QR', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isScannerPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                if (_isScannerPaused) {
                  _scannerController.start();
                  _isScannerPaused = false;
                } else {
                  _scannerController.stop();
                  _isScannerPaused = true;
                }
              });
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              _scannerController.toggleTorch().then((_) {
                setState(() {
                  _isTorchOn = !_isTorchOn;
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
