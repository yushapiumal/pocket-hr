// MAHAJANA Firebase project options.
//
// How to fill these in:
//   1. Go to https://console.firebase.google.com → select the MAHAJANA project
//   2. Project Settings → General → Your apps
//   3. Android app → download google-services.json  → copy values below
//   4. iOS app     → download GoogleService-Info.plist → copy values below
//
// See firebase_options_domex.dart for field mapping instructions.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class MahajanaFirebaseOptions {
  MahajanaFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web is not supported.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
            'Platform ${defaultTargetPlatform.name} is not supported.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_MAHAJANA_ANDROID_API_KEY',
    appId: 'REPLACE_MAHAJANA_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_MAHAJANA_SENDER_ID',
    projectId: 'REPLACE_MAHAJANA_PROJECT_ID',
    storageBucket: 'REPLACE_MAHAJANA_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_MAHAJANA_IOS_API_KEY',
    appId: 'REPLACE_MAHAJANA_IOS_APP_ID',
    messagingSenderId: 'REPLACE_MAHAJANA_SENDER_ID',
    projectId: 'REPLACE_MAHAJANA_PROJECT_ID',
    storageBucket: 'REPLACE_MAHAJANA_STORAGE_BUCKET',
    iosBundleId: 'REPLACE_MAHAJANA_IOS_BUNDLE_ID',
  );
}
