import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DisplayScannedInfo.dart';
import 'QrScannerPage.dart';
import 'ScannedInfo.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  ScannedInfo? _scannedInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner Example')),
      body: Center(
        child: _scannedInfo == null
            ? QrScannerPage(
          onScanned: (code) {
            setState(() {
              _scannedInfo = code;
            });
          },
        )
            : DisplayScannedInfo(
          scannedInfo: _scannedInfo!,
          onRescan: () {
            setState(() {
              _scannedInfo = null;
            });
          },
          onSync: () {
            debugPrint('Synchronisation des photos...');
          },
        ),
      ),
    );
  }
}