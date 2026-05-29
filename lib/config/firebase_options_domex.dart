// DOMEX Firebase project options.
//
// How to fill these in:
//   1. Go to https://console.firebase.google.com → select the DOMEX project
//   2. Project Settings → General → Your apps
//   3. Android app → download google-services.json  → copy values below
//   4. iOS app     → download GoogleService-Info.plist → copy values below
//
// Android fields (from google-services.json):
//   apiKey            → client[0].api_key[0].current_key
//   appId             → client[0].client_info.mobilesdk_app_id
//   messagingSenderId → project_info.project_number
//   projectId         → project_info.project_id
//   storageBucket     → project_info.storage_bucket
//
// iOS fields (from GoogleService-Info.plist):
//   apiKey            → API_KEY
//   appId             → GOOGLE_APP_ID
//   messagingSenderId → GCM_SENDER_ID
//   projectId         → PROJECT_ID
//   storageBucket     → STORAGE_BUCKET
//   iosBundleId       → BUNDLE_ID

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DomexFirebaseOptions {
  DomexFirebaseOptions._();

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
    apiKey: 'AIzaSyBdiBH_uJYTaDBEV5zP4JTOZF0oef1wrgM',
    appId: '1:1049172536794:android:bb1f279c3dc9225e2a24e3',
    messagingSenderId: '1049172536794',
    projectId: 'domex-go',
    storageBucket: 'domex-go.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIVLR8rVccNQKmxymprrzjmcm5Pw5T-PE',
    appId: '1:444016119144:ios:8340e3851e4cda07ee5add',
    messagingSenderId: '444016119144',
    projectId: 'pocket-hr-4ca30',
    storageBucket: 'pocket-hr-4ca30.firebasestorage.app',
    iosBundleId: 'asia.ceynet.human.pocket',
  );
}
