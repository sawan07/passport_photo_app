// lib/services/download_service_mobile.dart
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart'; // Import the package

import 'package:passport_photo_app/services/download_service.dart'; // Import the abstract service

// Mobile (Android/iOS) implementation of DownloadService
class DownloadServiceMobile implements DownloadService {
  @override
  Future<void> downloadFile(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    // Save the image to the device's gallery using image_gallery_saver_plus
    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      name: fileName,
      quality: 100, // Save with high quality
    );

    if (result['isSuccess']) {
      print('Photo saved to gallery: ${result['filePath']}');
      // You might want to show a SnackBar here in the UI layer
      // (e.g., by passing a callback or using a global messenger key)
    } else {
      print('Failed to save photo: ${result['errorMessage']}');
      throw Exception('Failed to save photo: ${result['errorMessage']}');
      // You might want to show a SnackBar here in the UI layer
    }
  }
}

// This function provides the mobile implementation when DownloadService() is called
// via the factory constructor in download_service.dart.
// It must have the same signature as the getDownloadService() in download_service.dart
// to correctly override it.
DownloadService getDownloadService() => DownloadServiceMobile();
