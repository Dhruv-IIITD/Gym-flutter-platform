import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'manual-config-required',
    appId: '1:000000000000:web:guru',
    messagingSenderId: '000000000000',
    projectId: 'wtf-flutter-test',
    authDomain: 'wtf-flutter-test.firebaseapp.com',
    storageBucket: 'wtf-flutter-test.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'manual-config-required',
    appId: '1:000000000000:android:guru',
    messagingSenderId: '000000000000',
    projectId: 'wtf-flutter-test',
    storageBucket: 'wtf-flutter-test.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'manual-config-required',
    appId: '1:000000000000:ios:guru',
    messagingSenderId: '000000000000',
    projectId: 'wtf-flutter-test',
    iosBundleId: 'com.wtf.guruApp',
    storageBucket: 'wtf-flutter-test.appspot.com',
  );
}
