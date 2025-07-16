// lib/services/download_service_web.dart
import 'dart:typed_data';
import 'dart:html' as html; // Using dart:html for web APIs

import 'package:passport_photo_app/services/download_service.dart'; // Import the abstract service

// Web-specific implementation of DownloadService
class DownloadServiceWeb implements DownloadService {
  @override
  Future<void> downloadFile(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    try {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      throw Exception('Web download failed: $e');
    }
  }
}

// This function provides the web implementation when DownloadService() is called
// via the factory constructor in download_service.dart.
// It must have the same signature as the getDownloadService() in download_service.dart
// to correctly override it.
DownloadService getDownloadService() => DownloadServiceWeb();
