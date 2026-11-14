import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.password = false,
    this.validator,
    this.keyboardType,
    this.last = false,
    this.enabled = true,
    this.onSubmit,
  });
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool password, last, enabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final VoidCallback? onSubmit;
  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _visible = false;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      validator: widget.validator,
      obscureText: widget.password && !_visible,
      autocorrect: !widget.password,
      enableSuggestions: !widget.password,
      keyboardType: widget.keyboardType,
      textInputAction: widget.last
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: (_) {
        if (widget.last) widget.onSubmit?.call();
      },
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.password
            ? IconButton(
                tooltip: _visible ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(
                  _visible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              )
            : null,
      ),
    ),
  );
}
