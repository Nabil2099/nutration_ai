import 'package:flutter/material.dart';

import 'app/bootstrap.dart';

export 'app/bootstrap.dart' show Bootstrap;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}
