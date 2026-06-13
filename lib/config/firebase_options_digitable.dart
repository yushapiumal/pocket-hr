// DIGITABLE Firebase project options.
//
// How to fill these in:
//   1. Go to https://console.firebase.google.com → select the DIGITABLE project
//   2. Project Settings → General → Your apps
//   3. Android app → download google-services.json  → copy values below
//   4. iOS app     → download GoogleService-Info.plist → copy values below
//
// See firebase_options_domex.dart for field mapping instructions.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DigitableFirebaseOptions {
  DigitableFirebaseOptions._();

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
    apiKey: 'AIzaSyAs2jL8Lox1iJIifbEgZ3GolyiZmlBknlw',
    appId: '1:444016119144:android:5802859fd5c6c78aee5add',
    messagingSenderId: '444016119144',
    projectId: 'pocket-hr-4ca30',
    storageBucket: 'pocket-hr-4ca30.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChHGzYofdgILci5bPdCpFMBclhbESBwT0',
    appId: '1:912364213375:ios:54c08693da5a2a7b8f5b4a',
    messagingSenderId: '912364213375',
    projectId: 'dsspa-73a47',
    storageBucket: 'dsspa-73a47.appspot.com',
    iosBundleId: 'com.example.statelink',
  );
}
