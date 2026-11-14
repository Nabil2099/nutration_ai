import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Until FlutterFire configuration is available, Android uses native config.
// Run tool/connect_firebase.dart after flutterfire configure to replace this
// file with the generated DefaultFirebaseOptions initialization.
Future<void> initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) return;
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    throw StateError(
      'Run flutterfire configure and dart run tool/connect_firebase.dart.',
    );
  }
  await Firebase.initializeApp();
}
