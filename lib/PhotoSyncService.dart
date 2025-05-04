import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoordinateurapp/ScannedInfo.dart';
import 'DeviceInfoHelper.dart'; // en haut

class PhotoSyncService {

  static Future<void> requestPermission() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isGranted) {
      // Permission granted, you can access photos and media files
    } else {
      throw Exception("Permission non accordée pour accéder aux photos.");
    }
  }

  static Future<List<AssetEntity>> getPhotosBetweenDates(
      DateTime startDate, DateTime endDate) async {

    await requestPermission();

    // Obtenir tous les albums
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );

    final List<AssetEntity> allAssets = await albums[0].getAssetListPaged(
      page: 0,
      size: 10000, // récupérer beaucoup d'images
    );

    // Filtrer selon les dates
    return allAssets.where((asset) {
      final date = asset.createDateTime;
      return date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          date.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
  }

  // Envoie une seule photo
  static Future<void> uploadPhoto(AssetEntity photo, ScannedInfo info) async {
    final File? file = await photo.file;
    if (file == null) return;

    final deviceName = await DeviceInfoHelper.getDeviceName();

    // Récupération du titre original de la photo (si disponible)
    final originalTitle = photo.title ?? 'photo'; // Utilisation du titre de la photo si disponible, sinon "photo"

    // Format de la date de création de la photo
    final fileDate = photo.createDateTime;
    if (fileDate == null) return;

    // Construction de l'URI avec les paramètres dans la query string
    final uri = Uri.parse('http://${info.ip}:${info.port}/upload/')
        .replace(queryParameters: {
      'DateTime': fileDate.toIso8601String(),
      'DeviceName': deviceName,
    });

    // Création de la requête multipart
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath('file', file.path, filename: originalTitle),
      );

    print('Sending request: ${request.toString()}');
    final response = await request.send();

    if (response.statusCode == 200) {
      print('✅ Photo envoyée : $originalTitle');
    } else {
      print('❌ Erreur en envoyant : $originalTitle');
    }
  }


  // Envoie toutes les photos
  static Future<void> uploadAllPhotos(List<AssetEntity> photos, ScannedInfo info) async {
    for (final photo in photos) {
      await uploadPhoto(photo, info);
    }
  }
}
