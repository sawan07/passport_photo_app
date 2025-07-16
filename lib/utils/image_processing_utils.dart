// lib/utils/image_processing_utils.dart
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:passport_photo_app/models/passport_spec.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart'; // Only used for non-web mock File creation

/// Core image processing logic: crops and resizes the image.
///
/// [originalImage]: The input image file.
/// [spec]: The PassportSpec containing target dimensions.
/// [outputPath]: The file path where the processed image will be saved (relevant for non-web).
Future<File?> resizeImageForPassport(
  File originalImage,
  PassportSpec spec,
  String outputPath,
) async {
  final bytes = await originalImage.readAsBytes();
  final image = img.decodeImage(bytes);

  if (image == null) {
    return null;
  }

  final double targetAspectRatio = spec.targetWidthPx / spec.targetHeightPx;

  int cropWidth = image.width;
  int cropHeight = (image.width / targetAspectRatio).round();

  if (cropHeight > image.height) {
    cropHeight = image.height;
    cropWidth = (image.height * targetAspectRatio).round();
  }

  final int offsetX = (image.width - cropWidth) ~/ 2;
  final int offsetY = (image.height - cropHeight) ~/ 2;

  final croppedImage = img.copyCrop(
    image,
    x: offsetX,
    y: offsetY,
    width: cropWidth,
    height: cropHeight,
  );

  final resizedImage = img.copyResize(
    croppedImage,
    width: spec.targetWidthPx.toInt(),
    height: spec.targetHeightPx.toInt(),
    interpolation: img.Interpolation.average,
  );

  final resizedBytes = img.encodeJpg(resizedImage, quality: 90);

  if (!kIsWeb) {
    final newFile = File(outputPath);
    await newFile.writeAsBytes(resizedBytes);
    return newFile;
  } else {
    // For web, create a mock File from bytes for display purposes.
    // The actual download uses the bytes directly from the screen's state.
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_processed_web_image.jpg');
    await tempFile.writeAsBytes(resizedBytes);
    return tempFile;
  }
}
