import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAjS7Q_IpcqhKA2i-OBVgYasp-3uBkEGMY',
    appId: '1:425034978224:web:5cc306e19528f4af523c75',
    messagingSenderId: '425034978224',
    projectId: 'e-icon-83a50',
    authDomain: 'e-icon-83a50.firebaseapp.com',
    storageBucket: 'e-icon-83a50.firebasestorage.app',
    measurementId: 'G-MP9FS7YMH6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_fuZeOClbMq31UQICMLJsmtfLTSpR9GY',
    appId: '1:425034978224:android:f93592eb8fd62d30523c75',
    messagingSenderId: '425034978224',
    projectId: 'e-icon-83a50',
    storageBucket: 'e-icon-83a50.firebasestorage.app',
  );
}
