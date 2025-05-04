import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'ScannedInfo.dart';

class QrScannerPage extends StatelessWidget {
  final Function(ScannedInfo code) onScanned;

  const QrScannerPage({super.key, required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (barcode) {
        String? code;
        if (barcode.barcodes.isNotEmpty &&
            barcode.barcodes[0].displayValue != null) {
          code = barcode.barcodes[0].displayValue;
        }

        if (code != null) {
          debugPrint('QR Code détecté: $code');
          final jsonData = jsonDecode(code);
          final info = ScannedInfo.fromJson(jsonData);
          onScanned(info);

        }
      },
    );
  }
}
