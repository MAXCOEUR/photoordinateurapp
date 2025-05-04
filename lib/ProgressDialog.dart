import 'package:flutter/material.dart';

class ProgressDialog extends StatefulWidget {
  final GlobalKey<ProgressDialogState> key;

  const ProgressDialog({
    required this.key,
  }) : super(key: key);

  @override
  ProgressDialogState createState() => ProgressDialogState();
}

class ProgressDialogState extends State<ProgressDialog> {
  int syncedPhotos = 0;
  int totalPhotos = 0 ;

  int state = 0;

  void setTotalPhotos(int newtotalPhotos) {
    setState(() {
      totalPhotos = newtotalPhotos;
      state = 1;
    });
    setSyncedPhotos(0);
  }

  void setSyncedPhotos(int newSyncedPhotos) {
    setState(() {
      syncedPhotos = newSyncedPhotos;
      if(syncedPhotos >= totalPhotos){
        state = 2;
      }
    });
  }

  void close(){
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Synchronisation des photos'),
      content: state==0? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Chargement des images'),
          SizedBox(height: 20),
          CircularProgressIndicator(),
        ],
      ):state==1?Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Synchronisation des photos: $syncedPhotos / ${totalPhotos}'),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: totalPhotos == 0 ? 0 : syncedPhotos / totalPhotos,
          ),
        ],
      ):Column(
        mainAxisSize: MainAxisSize.min,
          children: [
            Text('Toutes les photos ont été transférées avec succès. $syncedPhotos / ${totalPhotos}'),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: totalPhotos == 0 ? 0 : syncedPhotos / totalPhotos,
            ),
          ],
        ),
      actions: state==2
          ? [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Fermer'),
        ),
      ]
          : null,
    );
  }
}
