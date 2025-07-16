
# Passport Photo Resizer App

A Flutter application designed to help users resize and crop photos to meet specific passport photo requirements for various countries. This app also demonstrates integration with Firebase for potential AI-powered features like background removal.

---

## Table of Contents

- [Features](#features)  
- [Technologies Used](#technologies-used)  
- [Getting Started](#getting-started)  
  - [Prerequisites](#prerequisites)  
  - [Installation](#installation)  
  - [Firebase Setup (for AI Background Removal)](#firebase-setup-for-ai-background-removal)  
  - [Cloud Function Deployment (for AI Background Removal)](#cloud-function-deployment-for-ai-background-removal)  
- [How to Run the App](#how-to-run-the-app)  
- [Future Enhancements & Associate Developer Challenge](#future-enhancements--associate-developer-challenge)  
- [Contributing](#contributing)  
- [License](#license)  

---

## Features

- **Image Selection**: Pick photos from gallery or take a new photo using the camera.  
- **Country-Specific Resizing**: Automatically resize and crop images based on selected country (e.g., USA, UK, Canada).  
- **AI Background Removal** (with Firebase): Backend-powered removal of image backgrounds via Firebase Cloud Functions.  
- **Photo Preview**: View original and processed versions of the image.  
- **Download Processed Photo**: Save/download the background-removed or resized photo (including web download support).  
- **Portrait Orientation Lock**: Locked to portrait for consistent experience.  
- **Clean Architecture**: Organized codebase with clear separation of concerns.  
- **Platform-Specific Code Handling**: Shows how to manage platform-specific logic (e.g., file download).  

---

## Technologies Used

- **Flutter**: UI framework for mobile/web/desktop apps.  
- **Dart**: Language used by Flutter.  
- **image_picker**: For selecting/capturing photos.  
- **image**: Pure Dart image processing.  
- **path_provider**: File system paths.  
- **image_gallery_saver_plus**: Save images to mobile gallery.  
- **firebase_core**, **firebase_storage**, **cloud_functions**: Firebase integration.  
- **dart:html** (for Web): Used for browser-specific download logic.  

---

## Getting Started

Follow these instructions to run the project locally.

### Prerequisites

- Flutter SDK (3.x or newer)  
- Android Studio or VS Code with Flutter plugins  
- Firebase account  
- Firebase CLI  

### Installation

```bash
git clone <your-repository-url>
cd passport_photo_app
flutter pub get
```

#### Android NDK Fix (if needed)

Edit `android/app/build.gradle.kts`:

```kotlin
android {
    ndkVersion = "27.0.12077973"
    // ...
}
```

If using `image_gallery_saver_plus` and facing namespace issues, add:

```groovy
namespace 'com.example.image_gallery_saver_plus'
```

to the plugin’s `build.gradle`.

---

## Firebase Setup (for AI Background Removal)

1. Go to [Firebase Console](https://console.firebase.google.com/)  
2. Create a new project  
3. Add your Flutter app:

```bash
flutterfire configure
```

4. Update `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passport_photo_app/screens/passport_photo_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const PassportPhotoApp());
  });
}
```

5. Enable Firebase Services:

- Cloud Storage → Get Started  
- Cloud Functions → Get Started  

---

## Cloud Function Deployment (for AI Background Removal)

1. Navigate to the `functions` directory:

```bash
cd functions
npm install
```

2. Example `index.ts`:

```ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import * as path from "path";
import * as os from "os";
import * as fs from "fs";

admin.initializeApp();

export const removeImageBackground = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  }

  const imageUrl = data.imageUrl;
  if (!imageUrl) {
    throw new functions.https.HttpsError("invalid-argument", "imageUrl is required.");
  }

  try {
    const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
    const imageBuffer = Buffer.from(response.data);

    const tempFilePath = path.join(os.tmpdir(), 'temp_image.jpg');
    fs.writeFileSync(tempFilePath, imageBuffer);

    const bucket = admin.storage().bucket();
    const outputFileName = `background_removed/${Date.now()}_${path.basename(imageUrl, path.extname(imageUrl))}.png`;
    const file = bucket.file(outputFileName);

    await file.save(imageBuffer, {
      metadata: { contentType: 'image/png' },
    });

    const [downloadUrl] = await file.getSignedUrl({ action: 'read', expires: '03-09-2491' });
    return { backgroundRemovedImageUrl: downloadUrl };

  } catch (error) {
    console.error("Cloud Function Error:", error);
    throw new functions.https.HttpsError("internal", "Failed to process image background.");
  }
});
```

3. Deploy the function:

```bash
firebase deploy --only functions
```

---

## How to Run the App

Ensure all setup steps are complete.

### Mobile:

```bash
flutter run
```

### Web:

```bash
flutter run -d chrome
```

---

## Future Enhancements & Associate Developer Challenge

- **Dynamic Country Data (AI Challenge)**:
  - Use AI (OpenAI, Gemini) to fetch passport requirements dynamically.
  - Store results in Firestore/Supabase.
  - Update UI to use dynamic values.

- **Advanced Editing**: Brightness, contrast, manual cropping, etc.  
- **User Authentication**: Save personal images securely.  
- **Print Layouts**: Generate printable sheets.  
- **Cross-Platform Download**: Ensure consistent save/download across platforms.  
- **UI/UX Polish**: Improve design and animations.

---

## Contributing

Contributions are welcome! Fork the repo, make changes, and submit a pull request.

---

## License

This project is licensed under the [MIT License](LICENSE).
