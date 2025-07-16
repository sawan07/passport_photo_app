// lib/screens/passport_photo_screen.dart
import 'dart:io'; // For File operations (used for non-web platforms)
import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:image_picker/image_picker.dart'; // For picking images from gallery/camera
import 'package:flutter/foundation.dart'
    show kIsWeb; // To check if the app is running on web
import 'package:path_provider/path_provider.dart'; // For getting temporary directory to save processed images (non-web)

// No direct dart:html import here anymore.
// The download service will handle platform-specific imports.

import 'package:passport_photo_app/models/passport_spec.dart';
import 'package:passport_photo_app/utils/image_processing_utils.dart';
import 'package:passport_photo_app/utils/snackbar_utils.dart';
import 'package:passport_photo_app/services/download_service.dart'; // Import the new download service

class PassportPhotoScreen extends StatefulWidget {
  const PassportPhotoScreen({super.key});

  @override
  State<PassportPhotoScreen> createState() => _PassportPhotoScreenState();
}

class _PassportPhotoScreenState extends State<PassportPhotoScreen> {
  File? _pickedImage; // Stores the original image picked by the user
  File? _processedImage; // Stores the resized/cropped passport photo
  bool _isLoading = false; // To show loading indicator during processing
  PassportSpec?
  _selectedCountrySpec; // The currently selected country's photo specifications

  @override
  void initState() {
    super.initState();
    _selectedCountrySpec = passportSpecs.first;
  }

  /// Handles picking an image from the device's gallery or taking a new one with the camera.
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _pickedImage = File(pickedFile.path);
                        _processedImage = null;
                      });
                    }
                  } catch (e) {
                    showSnackBar(
                      context,
                      'Error picking image from gallery: $e',
                      Colors.red,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _pickedImage = File(pickedFile.path);
                        _processedImage = null;
                      });
                    }
                  } catch (e) {
                    showSnackBar(
                      context,
                      'Error taking picture: $e',
                      Colors.red,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Generates the passport photo based on the selected image and country specifications.
  Future<void> _generatePassportPhoto() async {
    if (_pickedImage == null) {
      showSnackBar(context, 'Please pick an image first.', Colors.orange);
      return;
    }
    if (_selectedCountrySpec == null) {
      showSnackBar(context, 'Please select a country.', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String outputPath;
      if (kIsWeb) {
        outputPath =
            ''; // Not used for direct file saving on web, just a placeholder
      } else {
        final directory = await getTemporaryDirectory();
        outputPath =
            '${directory.path}/passport_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }

      final processedFile = await resizeImageForPassport(
        _pickedImage!,
        _selectedCountrySpec!,
        outputPath,
      );

      setState(() {
        _processedImage = processedFile;
      });

      if (processedFile != null) {
        showSnackBar(
          context,
          'Passport photo generated successfully!',
          Colors.green,
        );
      } else {
        showSnackBar(context, 'Failed to generate passport photo.', Colors.red);
      }
    } catch (e) {
      showSnackBar(context, 'Error processing image: $e', Colors.red);
      print('Error processing image: $e'); // Log error for debugging
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Triggers a download of the processed photo.
  Future<void> _downloadProcessedPhoto() async {
    if (_processedImage == null) {
      showSnackBar(context, 'No processed photo to download.', Colors.orange);
      return;
    }

    try {
      final bytes = await _processedImage!.readAsBytes();
      await DownloadService().downloadFile(
        bytes,
        'passport_photo_${_selectedCountrySpec!.country}.jpg',
        'image/jpeg',
      );
      showSnackBar(context, 'Photo download initiated!', Colors.green);
    } catch (e) {
      showSnackBar(context, 'Error downloading photo: $e', Colors.red);
      print('Error downloading photo: $e'); // Log error for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive image display
    final screenWidth = MediaQuery.of(context).size.width;
    final imageDisplaySize = screenWidth * 0.8; // 80% of screen width

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passport Photo Resizer'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Country Selection Dropdown
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Select Country:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<PassportSpec>(
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        value: _selectedCountrySpec,
                        items:
                            passportSpecs.map((PassportSpec spec) {
                              return DropdownMenuItem<PassportSpec>(
                                value: spec,
                                child: Text(
                                  '${spec.country} (${spec.widthMm}x${spec.heightMm} mm)',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                        onChanged: (PassportSpec? newValue) {
                          setState(() {
                            _selectedCountrySpec = newValue;
                            _processedImage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Pick Image Button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),

              // Original Image Preview
              if (_pickedImage != null)
                Column(
                  children: [
                    const Text(
                      'Original Image:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      clipBehavior:
                          Clip.antiAlias, // Ensures image respects card border radius
                      child: Image.file(
                        _pickedImage!,
                        height: imageDisplaySize,
                        width: imageDisplaySize,
                        fit:
                            BoxFit
                                .contain, // Contain to show full image without cropping
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Generate Button & Loading Indicator
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                    onPressed: _generatePassportPhoto,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Generate Passport Photo'),
                  ),
              const SizedBox(height: 20),

              // Processed Image Preview
              if (_processedImage != null)
                Column(
                  children: [
                    const Text(
                      'Processed Passport Photo:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      clipBehavior:
                          Clip.antiAlias, // Ensures image respects card border radius
                      child: Image.file(
                        _processedImage!,
                        height: imageDisplaySize,
                        width:
                            imageDisplaySize *
                            (_selectedCountrySpec!.targetWidthPx /
                                _selectedCountrySpec!
                                    .targetHeightPx), // Adjust width based on aspect ratio
                        fit:
                            BoxFit
                                .cover, // Cover to fill the space, showing the cropped result
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_selectedCountrySpec!.country} - ${_selectedCountrySpec!.widthMm.toInt()}x${_selectedCountrySpec!.heightMm.toInt()} mm',
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _downloadProcessedPhoto,
                      icon: const Icon(Icons.download),
                      label: const Text('Download Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
