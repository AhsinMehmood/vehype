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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidBeta;
      case TargetPlatform.iOS:
        return iosBeta;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUX7TVUM2XOZJwv7GQ_2sTeZOj4SseDzk',
    appId: '1:832920203889:android:200544c1b271499bcce1d0',
    messagingSenderId: '832920203889',
    projectId: 'vehype-386313',
    databaseURL: 'https://vehype-386313-default-rtdb.firebaseio.com',
    storageBucket: 'vehype-386313.appspot.com',
  );

  static const FirebaseOptions androidBeta = FirebaseOptions(
    apiKey: 'AIzaSyAjTQwQ3b74CucTIL2gE1cHXcZ5pZmVKrs',
    appId: '1:595427669329:android:362c8b6549a1e63467cf70',
    messagingSenderId: '595427669329',
    projectId: 'vehype-98f5e',
    databaseURL: 'https://vehype-98f5e-default-rtdb.firebaseio.com',
    storageBucket: 'vehype-98f5e.appspot.com',
  );
  static const FirebaseOptions iosBeta = FirebaseOptions(
    apiKey: 'AIzaSyA8c2j0xocvV-mhOHvBFcwe7LCEVzFj2EQ',
    appId: '1:595427669329:ios:40d8a0e4445416ea67cf70',
    messagingSenderId: '595427669329',
    projectId: 'vehype-98f5e',
    databaseURL: 'https://vehype-98f5e-default-rtdb.firebaseio.com',
    storageBucket: 'vehype-98f5e.appspot.com',
    androidClientId:
        '595427669329-ae83qkekslrjemhtvqc9vkd3bpdb14er.apps.googleusercontent.com',
    iosClientId:
        '595427669329-rjmcj7quh0ct1jps6nl0kms706ffndlc.apps.googleusercontent.com',
    iosBundleId: 'com.nomadllc.vehype.beta',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAK6KvCmEG7qqs-uE8XnIc8UgltGT-bmuM',
    appId: '1:832920203889:ios:7f1cf1482827a5d2cce1d0',
    messagingSenderId: '832920203889',
    projectId: 'vehype-386313',
    databaseURL: 'https://vehype-386313-default-rtdb.firebaseio.com',
    storageBucket: 'vehype-386313.appspot.com',
    androidClientId:
        '832920203889-5e5jgnoecueoahn8qkg29d5bplg2m578.apps.googleusercontent.com',
    iosClientId:
        '832920203889-ssnm89qn4rq0j8lof7qkpsm2dkumlcsc.apps.googleusercontent.com',
    iosBundleId: 'com.nomadllc.vehype',
  );
}
