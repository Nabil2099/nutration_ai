import 'package:flutter/material.dart';

import '../widgets/auth_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key, required this.onSwitch});
  final VoidCallback onSwitch;
  @override
  Widget build(BuildContext context) =>
      AuthForm(register: true, onSwitch: onSwitch);
}
