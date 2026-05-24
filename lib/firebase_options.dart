// ─────────────────────────────────────────────────────────────────────────────
// STUB — replace this file by running:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command will:
//   1. Let you select your Firebase project (or create one)
//   2. Register Android + iOS apps automatically
//   3. Overwrite this file with real API keys
//   4. Place google-services.json in android/app/
//   5. Place GoogleService-Info.plist in ios/Runner/
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions: unsupported platform. '
          'Run `flutterfire configure` to generate real options.',
        );
    }
  }

  // ── Replace the values below with the output of `flutterfire configure` ──

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.churchapp',
  );
}
