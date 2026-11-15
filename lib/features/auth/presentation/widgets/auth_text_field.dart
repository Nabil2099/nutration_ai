import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
    this.topTrailing,
    this.trailingDot = false,
    this.bottomSpacing = 12,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool password;
  final bool last;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final VoidCallback? onSubmit;
  final Widget? topTrailing;
  final bool trailingDot;
  final double bottomSpacing;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _visible = false;

  @override
  void didUpdateWidget(covariant AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.password && _visible) {
      _visible = false;
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: widget.bottomSpacing),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.topTrailing != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 3, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: widget.topTrailing,
            ),
          ),
        TextFormField(
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
            prefixIcon: Icon(widget.icon, color: AppColors.textSecondary),
            suffixIcon: widget.password
                ? IconButton(
                    tooltip: _visible ? 'Hide password' : 'Show password',
                    onPressed: () => setState(() => _visible = !_visible),
                    icon: Icon(
                      _visible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                  )
                : widget.trailingDot
                ? const Icon(
                    Icons.circle,
                    size: 10,
                    color: AppColors.primaryBright,
                  )
                : null,
          ),
        ),
      ],
    ),
  );
}
