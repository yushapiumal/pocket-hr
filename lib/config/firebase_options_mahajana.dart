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
    apiKey: 'AIzaSyAaEv5pqk_6Oh86WVcgHDNg08igJrwMbLM',
    appId: '1:71892141807:android:35bdf73b281be00be6fd1a',
    messagingSenderId: '71892141807',
    projectId: 'mahajana-hr',
    storageBucket: 'mahajana-hr.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_MAHAJANA_IOS_API_KEY',
    appId: 'REPLACE_MAHAJANA_IOS_APP_ID',
    messagingSenderId: '71892141807',
    projectId: 'mahajana-hr',
    storageBucket: 'mahajana-hr.firebasestorage.app',
    iosBundleId: 'io.digitable.go.mahajana.human',
  );
}
