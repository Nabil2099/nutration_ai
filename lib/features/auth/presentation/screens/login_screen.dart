import 'package:flutter/material.dart';

import '../widgets/auth_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.onSwitch});
  final VoidCallback onSwitch;
  @override
  Widget build(BuildContext context) => AuthForm(
    key: const ValueKey('login_form'),
    register: false,
    onSwitch: onSwitch,
  );
}
