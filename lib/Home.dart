import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DisplayScannedInfo.dart';
import 'PhotoSyncService.dart';
import 'QrScannerPage.dart';
import 'ScannedInfo.dart';
import 'constante.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> with WidgetsBindingObserver {
  ScannedInfo? _scannedInfo;


  Future<bool> isConnected(ScannedInfo scannedInfo) async{
    if(!await PhotoSyncService.testConnexion(scannedInfo)){
      return false;
    }
    return true;
  }
  void resetScann(){
    setState(() {
      _scannedInfo = null;
    });
  }

  Future<void> onAfterScan(ScannedInfo scannedInfo) async {
    // Affiche le loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // empêche de fermer manuellement
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Test de connexion..."),
          ],
        ),
      ),
    );

    // Test de la connexion
    final connected = await isConnected(scannedInfo);

    // Ferme le loading dialog
    Navigator.of(context).pop();

    // Si la connexion échoue
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La connexion est impossible, l'adresse IP ou le port n'est pas bon")),
      );
      resetScann();
      return;
    }

    // Connexion réussie, on met à jour l'état
    setState(() {
      _scannedInfo = scannedInfo;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PhotoOrdinateur')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Constants.backgroundColor,
        child: Center(
            child: _scannedInfo == null
                ? QrScannerPage(
              onScanned: onAfterScan,
            )
                : DisplayScannedInfo(
              scannedInfo: _scannedInfo!,
              onRescan: resetScann,
              onSync: () {
                debugPrint('Synchronisation des photos...');
              },
            ),
          ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if(_scannedInfo != null){
        onAfterScan(_scannedInfo!);
      }
    }
  }
}