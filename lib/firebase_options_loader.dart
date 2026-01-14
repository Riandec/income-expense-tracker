import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A class that loads FirebaseOptions dynamically from environment variables.
/// This maintains the same structure as the auto-generated firebase_options.dart.
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

  // Helper function to get a required environment variable
  static String _getRequired(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('Missing required environment variable: $key');
    }
    return value;
  }

  static FirebaseOptions get web {
    return FirebaseOptions(
      apiKey: _getRequired('API_KEY_WEB'),
      appId: _getRequired('APP_ID_WEB'),
      messagingSenderId: _getRequired('MESSAGING_SENDER_ID_WEB'),
      projectId: _getRequired('PROJECT_ID_WEB'),
      authDomain: _getRequired('AUTH_DOMAIN_WEB'),
      storageBucket: _getRequired('STORAGE_BUCKET_WEB'),
      measurementId: _getRequired('MEASUREMENT_ID_WEB'),
    );
  }

  static FirebaseOptions get android {
    return FirebaseOptions(
      apiKey: _getRequired('API_KEY_ANDROID'),
      appId: _getRequired('APP_ID_ANDROID'),
      messagingSenderId: _getRequired('MESSAGING_SENDER_ID_ANDROID'),
      projectId: _getRequired('PROJECT_ID_ANDROID'),
      storageBucket: _getRequired('STORAGE_BUCKET_ANDROID'),
    );
  }

  static FirebaseOptions get ios {
    return FirebaseOptions(
      apiKey: _getRequired('API_KEY_IOS'),
      appId: _getRequired('APP_ID_IOS'),
      messagingSenderId: _getRequired('MESSAGING_SENDER_ID_IOS'),
      projectId: _getRequired('PROJECT_ID_IOS'),
      storageBucket: _getRequired('STORAGE_BUCKET_IOS'),
      iosBundleId: _getRequired('IOS_BUNDLE_ID'),
    );
  }
}