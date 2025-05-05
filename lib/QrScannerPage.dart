import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'ScannedInfo.dart';
import 'constante.dart';

class QrScannerPage extends StatefulWidget {
  final Function(ScannedInfo code) onScanned;

  const QrScannerPage({super.key, required this.onScanned});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool showManualEntry = false;

  final ipController = TextEditingController();
  final portController = TextEditingController();

  void _toggleView() {
    setState(() {
      showManualEntry = !showManualEntry;
    });
  }

  void _submitManual() {
    final ip = ipController.text.trim();
    final port = int.tryParse(portController.text);



    // Si l'IP et le port sont valides, on appelle la méthode onScanned
    verifyScannedInfo(ScannedInfo(ip: ip, port: port));
  }

  void verifyScannedInfo(ScannedInfo scannedInfo) {
    // Expression régulière pour valider une adresse IPv4
    final RegExp ipRegex = RegExp(
        r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.('
        r'25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.('
        r'25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.('
        r'25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );

    // Vérification de l'IP et du port
    if (scannedInfo.ip.isEmpty || !ipRegex.hasMatch(scannedInfo.ip)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adresse IP invalide. Veuillez entrer une adresse IPv4 correcte.')),
      );
      return;
    }

    if (scannedInfo.port == null || scannedInfo.port! < 1 || scannedInfo.port! > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Port invalide. Veuillez entrer un port valide (1-65535).')),
      );
      return;
    }

    widget.onScanned(scannedInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton.icon(
            onPressed: _toggleView,
            icon: Icon(
              showManualEntry ? Icons.qr_code_scanner : Icons.edit,
              color: Constants.buttonColor,
            ),
            label: Text(
              showManualEntry ? 'Scanner un QR Code' : 'Saisie manuelle',
              style: TextStyle(color: Constants.buttonColor),
            ),
          ),
        ),
        Expanded(
          child: showManualEntry
              ? Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: ipController,
                  style: const TextStyle(color: Constants.textColor),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Adresse IP',
                    labelStyle: TextStyle(color: Constants.textColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: portController,
                  style: const TextStyle(color: Constants.textColor),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Port',
                    labelStyle: TextStyle(color: Constants.textColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _submitManual,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Valider', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          )
              : MobileScanner(
            onDetect: (barcode) {
              String? code;
              if (barcode.barcodes.isNotEmpty &&
                  barcode.barcodes[0].displayValue != null) {
                code = barcode.barcodes[0].displayValue;
              }

              if (code != null) {
                debugPrint('QR Code détecté: $code');
                final jsonData = jsonDecode(code);
                ScannedInfo info = ScannedInfo.fromJson(jsonData);
                verifyScannedInfo(info);
              }
            },
          ),
        ),
      ],
    );
  }
}
