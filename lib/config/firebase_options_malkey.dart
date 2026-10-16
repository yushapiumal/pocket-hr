import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class MalkeyFirebaseOptions {
  MalkeyFirebaseOptions._();

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
    apiKey: 'AIzaSyBx3O2aV7osrjAsjFaj2aJ9079VgKXJCz0',
    appId: '1:1049172536794:ios:bc4e0e0a5cf0015c2a24e3',
    messagingSenderId: '1049172536794',
    projectId: 'domex-go',
    storageBucket: 'domex-go.firebasestorage.app',
    iosBundleId: 'io.digitable.go.malkey.human',
  );
}
