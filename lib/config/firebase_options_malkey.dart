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
    apiKey: 'AIzaSyCc1Tv5JfvS4b2DU2YL1DY27_9uyBpwRBc',
    appId: '1:759243690029:android:9cf12031827149734628a4',
    messagingSenderId: '759243690029',
    projectId: 'malkeyfront-8c8c3',
    storageBucket: 'malkeyfront-8c8c3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCc1Tv5JfvS4b2DU2YL1DY27_9uyBpwRBc',
    appId: '1:759243690029:ios:bc4e0e0a5cf0015c2a24e3',
    messagingSenderId: '759243690029',
    projectId: 'malkeyfront-8c8c3',
    storageBucket: 'malkeyfront-8c8c3.firebasestorage.app',
    iosBundleId: 'io.digitable.go.malkey.human',
  );
}
