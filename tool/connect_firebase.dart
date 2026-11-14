import 'dart:io';

// Run after the official FlutterFire CLI has generated real configuration.
void main() {
  if (!File('lib/firebase_options.dart').existsSync()) {
    stderr.writeln(
      'Run flutterfire configure first. No configuration was changed.',
    );
    exitCode = 1;
    return;
  }
  File('lib/core/firebase_bootstrap.dart').writeAsStringSync(
    "import 'package:firebase_core/firebase_core.dart';\nimport '../firebase_options.dart';\nFuture<void> initializeFirebase() async {\n  if (Firebase.apps.isEmpty) {\n    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);\n  }\n}\n",
  );
  stdout.writeln('Connected Firebase bootstrap to generated options.');
}
