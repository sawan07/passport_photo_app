// lib/services/download_service.dart
import 'dart:typed_data';

// This file defines the abstract interface and the factory constructor.
// It conditionally imports the platform-specific implementation.

// Conditional import for platform-specific implementation.
// The 'as' keyword is crucial here for the conditional import to work correctly.
// If dart.library.html is available (web), it imports download_service_web.dart.
// Otherwise (non-web), it imports download_service_mobile.dart.
import 'package:passport_photo_app/services/download_service_mobile.dart'
    if (dart.library.html) 'package:passport_photo_app/services/download_service_web.dart';

// Abstract class defining the contract for download service.
abstract class DownloadService {
  // Factory constructor that delegates to the platform-specific getDownloadService().
  factory DownloadService() => getDownloadService();

  // Abstract method for downloading a file.
  Future<void> downloadFile(Uint8List bytes, String fileName, String mimeType);
}

// This function's actual implementation is provided by the conditionally imported
// platform-specific file (download_service_mobile.dart or download_service_web.dart).
// Its definition here serves as a 'stub' that will be overridden.
// If for some reason no concrete implementation is provided by the import,
// this UnsupportedError will be thrown.
DownloadService getDownloadService() =>
    throw UnsupportedError(
      'Cannot create a DownloadService without a concrete implementation for the current platform.',
    );
