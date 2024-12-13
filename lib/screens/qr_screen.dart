import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
  String _scannedCode = 'No code scanned yet';
  bool _isScannerPaused = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    // Always dispose the controller when not in use
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final Barcode barcode = barcodes.first;

      setState(() {
        _scannedCode = barcode.rawValue ?? 'No data';
        _isScannerPaused = true;
      });

      // Optional: Show a dialog with the scanned code
      _showScannedCodeDialog(barcode.rawValue);
    }
  }

  void _showScannedCodeDialog(String? code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scanned QR Code'),
          content: Text(code ?? 'No data'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
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
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue.shade600,
              child: Center(
                child: Text(
                  'Scanned Code: $_scannedCode',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
