import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'ScannedInfo.dart';
import 'PhotoSyncService.dart';
import 'ProgressDialog.dart';  // Assure-toi d'importer le widget ProgressDialog

class DisplayScannedInfo extends StatefulWidget {
  final ScannedInfo scannedInfo;
  final VoidCallback onRescan;
  final VoidCallback onSync;

  const DisplayScannedInfo({
    super.key,
    required this.scannedInfo,
    required this.onRescan,
    required this.onSync,
  });

  @override
  _DisplayScannedInfoState createState() => _DisplayScannedInfoState();
}

class _DisplayScannedInfoState extends State<DisplayScannedInfo> {
  late BuildContext dialogContext; // Pour garder une référence du context du dialog

  late GlobalKey<ProgressDialogState> progressDialogKey; // GlobalKey pour accéder à ProgressDialog

  @override
  void initState() {
    super.initState();
    progressDialogKey = GlobalKey<ProgressDialogState>(); // Initialise la clé
  }

  // Méthode pour afficher la popup de progression
  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche de fermer la popup en dehors
      builder: (BuildContext context) {
        dialogContext = context;
        return ProgressDialog(
          key: progressDialogKey, // Passe la clé globale au widget
        );
      },
    );
  }

  Future<void> _pickDatesAndSync(BuildContext context) async {
    try{
      final DateTimeRange? range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );

      if (range != null) {

        // Ouvrir la popup de progression
        WakelockPlus.enable();
        _showProgressDialog(context);

        final photos = await PhotoSyncService.getPhotosBetweenDates(
          range.start,
          range.end,
        );

        // Debug: Affiche combien de photos ont été trouvées
        debugPrint('Nombre de photos trouvées : ${photos.length}');
        int totalPhotos = photos.length;

        if (dialogContext.mounted) {
          // Récupérer l'état de ProgressDialog via la clé et mettre à jour la progression
          progressDialogKey.currentState?.setTotalPhotos(totalPhotos); // Met à jour le nombre de photos synchronisées
        }

        // Synchroniser les photos une par une pour mettre à jour l'avancement
        for (int i = 0; i < photos.length; i++) {
          await PhotoSyncService.uploadPhoto(photos[i], widget.scannedInfo);

          // Mettez à jour la progression dynamique dans la popup
          if (dialogContext.mounted) {
            // Récupérer l'état de ProgressDialog via la clé et mettre à jour la progression
            progressDialogKey.currentState?.setSyncedPhotos(i + 1); // Met à jour le nombre de photos synchronisées
          }
        }
      }
      WakelockPlus.disable();
      widget.onSync();
    }catch(e){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Une erreur est survenue : $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                progressDialogKey.currentState?.close();
                },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('IP: ${widget.scannedInfo.ip}'),
        Text('Port: ${widget.scannedInfo.port}'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: widget.onRescan,
          child: const Text('Re-scanner'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _pickDatesAndSync(context),
          child: const Text('Synchroniser les photos'),
        ),
      ],
    );
  }
}
