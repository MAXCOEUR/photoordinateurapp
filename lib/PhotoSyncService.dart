import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:photoordinateurapp/ScannedInfo.dart';
import 'DeviceInfoHelper.dart'; // en haut

class PhotoSyncService {

  static Future<void> requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      // Permission granted, you can access photos and media files
    } else {
      throw Exception("Permission non accordée pour accéder aux photos.");
    }
  }

  static Future<List<AssetEntity>> getPhotosBetweenDates(
      DateTime startDate, DateTime endDate) async {
    endDate = endDate.add(Duration(days: 1));
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
    List<AssetEntity> test =  allAssets.where((asset) {
      final date = asset.createDateTime;
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).toList();

    return test;
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

  // Envoie un test
  static Future<bool> testConnexion(ScannedInfo info) async {
    final uri = Uri.parse('http://${info.ip}:${info.port}/test/');

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 5)); // Timeout ajouté ici
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur de connexion : $e");
      return false;
    }
  }

}
