// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyA2aDA1ZFrGjX9o6isBvMhUQaZPyKArwOE',
    appId: '1:356284806672:web:1ce73a924896170758fc95',
    messagingSenderId: '356284806672',
    projectId: 'handa-ffa31',
    authDomain: 'handa-ffa31.firebaseapp.com',
    storageBucket: 'handa-ffa31.firebasestorage.app',
    measurementId: 'G-6FVP7R0B65',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJzfJInY-udqRb27VH5dIQNcSrjPs4ycg',
    appId: '1:356284806672:android:bbae60d849758a6458fc95',
    messagingSenderId: '356284806672',
    projectId: 'handa-ffa31',
    storageBucket: 'handa-ffa31.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUddOBLiN2kB0Y7J1LD_s9Sg6ioo6-eqw',
    appId: '1:356284806672:ios:7a00f756047d06bc58fc95',
    messagingSenderId: '356284806672',
    projectId: 'handa-ffa31',
    storageBucket: 'handa-ffa31.firebasestorage.app',
    iosBundleId: 'com.example.handa',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCUddOBLiN2kB0Y7J1LD_s9Sg6ioo6-eqw',
    appId: '1:356284806672:ios:7a00f756047d06bc58fc95',
    messagingSenderId: '356284806672',
    projectId: 'handa-ffa31',
    storageBucket: 'handa-ffa31.firebasestorage.app',
    iosBundleId: 'com.example.handa',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA2aDA1ZFrGjX9o6isBvMhUQaZPyKArwOE',
    appId: '1:356284806672:web:20cea2b6b43d0c2458fc95',
    messagingSenderId: '356284806672',
    projectId: 'handa-ffa31',
    authDomain: 'handa-ffa31.firebaseapp.com',
    storageBucket: 'handa-ffa31.firebasestorage.app',
    measurementId: 'G-58PMQWQY6Z',
  );

}